import re
from typing import Set, Dict, Any, List, Tuple

from CppHeaderParser import CppHeader

from valacefgen.types import Repository, EnumValue, Enum, Struct, Typedef, StructMember, Delegate, Function, Type, \
    StructVirtualFunc, OpaqueClass
from valacefgen.utils import find_prefix, lstrip, rstrip, camel_case
from valacefgen import utils


class Naming:
    def __init__(self, strip_prefix: str):
        self.strip_prefix = strip_prefix

    def enum(self, name: str) -> str:
        """Generate Vala name for enum names (not members)."""
        return camel_case(rstrip(lstrip(name, self.strip_prefix.lower() + "_"), '_t'))

    def struct(self, name: str) -> str:
        return camel_case(rstrip(lstrip(name, self.strip_prefix.lower() + "_"), '_t'))

    def typedef(self, name: str) -> str:
        """Generate Vala name for typedef's alias."""
        return camel_case(rstrip(lstrip(name, self.strip_prefix.lower() + "_"), '_t'))

    def camel_case(self, name: str) -> str:
        return camel_case(rstrip(lstrip(name, self.strip_prefix.lower() + "_"), '_t'))

    def delegate(self, prefix: str, name: str) -> str:
        return self.camel_case(prefix) + self.camel_case(name) + 'Func'

    def function(self, name: str) -> str:
        return lstrip(name, self.strip_prefix.lower() + "_")


class Parser:
    def __init__(self, naming: Naming, repo: Repository, ignore: Set[str], base_structs: Set[str],
                 base_classes: Set[str]):
        self.base_classes = base_classes
        self.base_structs = base_structs
        self.ignore = ignore
        self.naming = naming
        self.repo = repo
        self.vala_glue: List[Type] = []
        self.c_glue: List[Type] = []

    def preprocess_header(self, data: str) -> str:
        data = data.replace('CEF_EXPORT', '').replace('CEF_CALLBACK', '')
        COMMENT_RE = re.compile(r'^\n?(\s*)///\s*\n((?:\s*//(.*?)\n)+)\s*///\s*\n', re.MULTILINE)

        def repl(match):
            return match.group(1) + '/**\n' + match.group(2) + match.group(1) + ' */\n'

        return COMMENT_RE.sub(repl, data)

    def parse_header(self, path: str, c_include_path: str):
        with open(path) as f:
            data = self.preprocess_header(f.read())
        header = CppHeader(data, 'string')
        self.parse_typedefs(c_include_path, header.typedefs)
        self.parse_enums(c_include_path, header.enums)
        self.parse_classes_and_structs(c_include_path, header.classes)
        self.parse_functions(c_include_path, header.functions)

    def parse_typedefs(self, c_include_path: str, typedefs):
        for alias, c_type in typedefs.items():
            if alias not in self.ignore:
                self.parse_typedef(c_include_path, alias, c_type)

    def parse_typedef(self, c_include_path: str, alias: str, c_type: str):
        if c_type in ("void*", "void *"):
            self.repo.add_opaque_class(OpaqueClass(
                basename=rstrip(alias, 't'),
                c_name=alias,
                vala_name=self.naming.struct(alias),
                c_header=c_include_path,
                c_type='void'))
        else:
            bare_c_type = utils.bare_c_type(c_type)
            self.repo.add_typedef(Typedef(
                c_name=alias,
                vala_name=self.naming.typedef(alias),
                c_type=bare_c_type,
                c_header=c_include_path))

    def parse_functions(self, c_include_path: str, functions):
        for func in functions:
            name = func['name']
            if name not in self.ignore:
                self.parse_function(c_include_path, name, func)

    def parse_function(self, c_include_path: str, func_name: str, func: Dict[str, Any]):
        function = Function(
            c_name=func_name,
            vala_name=self.naming.function(func_name),
            c_header=c_include_path,
            ret_type=func['rtnType'],
            params=[(p['type'], p['name']) for p in func['parameters']],
            comment=func.get('doxygen'))
        for basename, klass in self.repo.basenames.items():
            if func_name.startswith(basename):
                klass.add_method(function)
                break
        else:
            self.repo.add_function(function)

    def parse_enums(self, c_include_path: str, enums):
        for enum in enums:
            if enum['typedef']:
                name = enum['name']
                # For vala names, we strip the common prefix to make enum member names shorter.
                n_prefix = len(find_prefix([v['name'] for v in enum['values']]))
                values = [EnumValue(
                    v['name'],   # c_name
                    v['name'][n_prefix:],  # vala_name
                    v.get('doxygen')  # comment
                    ) for v in enum['values'] if v['name'] not in self.ignore]
                self.repo.add_enum(Enum(
                    c_name=name,
                    vala_name=self.naming.enum(name),
                    c_header=c_include_path,
                    values=values))
            else:
                raise NotImplementedError

    def parse_classes_and_structs(self, c_include_path: str, classes_and_structs):
        for name, candidate in classes_and_structs.items():
            if candidate['declaration_method'] == 'class':
                raise NotImplementedError(name)
            else:  # struct
                self.parse_struct(c_include_path, name, candidate)

    def parse_struct(self, c_include_path: str, struct_name: str, struct):
        properties = struct['properties']
        struct_members = []
        struct_virtual_funcs = []
        for member in properties["public"]:
            c_name = member["name"]
            c_type = member["type"]
            if member['function_pointer']:
                if utils.is_func_pointer(c_type):
                    ret_type, params = utils.parse_c_func_pointer(c_type)
                else:
                    ret_type = member['type']
                    params = [(struct_name + '*', 'self')]
                vala_type = self.naming.delegate(struct_name, c_name)
                # Delegates (pointers to functions) are not type-defined in CEF C headers.
                self.add_c_glue(Delegate(
                    c_name=vala_type,
                    vala_name=vala_type,
                    c_header="",
                    ret_type=ret_type,
                    params=params,
                    vfunc_of_class=struct_name,
                    vfunc_name=c_name if params[0][1] == "self" else None,
                ))
                self.repo.add_delegate(Delegate(
                    c_name=vala_type,
                    vala_name=vala_type,
                    c_header="valacef_api.h",  # Generated typedef is there.
                    ret_type=ret_type,
                    params=params,
                    vfunc_of_class=struct_name))
                struct_members.append(StructMember(
                    c_type=vala_type,
                    c_name=c_name,
                    vala_name="vfunc_" + c_name,
                    comment=member.get('doxygen')))
                struct_virtual_funcs.append(StructVirtualFunc(
                    c_name="%s_%s" % (struct_name, c_name),
                    vala_name=c_name,
                    ret_type=ret_type,
                    params=params,
                    comment=member.get('doxygen')))
            else:
                assert not member['function_pointer'] and not utils.is_func_pointer(c_type), member
                struct_members.append(StructMember(
                    c_type=utils.normalize_pointer(c_type),
                    c_name=c_name,
                    vala_name=c_name,
                    comment=member.get('doxygen')))
        self.repo.add_struct(Struct(
            c_name=struct_name,
            vala_name=self.naming.struct(struct_name),
            c_header=c_include_path,
            members=struct_members,
            virtual_funcs=struct_virtual_funcs,
            comment=struct.get('doxygen')))

    def add_vala_glue(self, *glue: Type):
        self.vala_glue.extend(glue)

    def add_c_glue(self, *glue: Type):
        self.c_glue.extend(glue)

    def finish(self) -> Tuple[str, str, str, str]:
        self.resolve_struct_parents()
        self.wrap_simple_classes()
        return (
            self.create_valacef_vapi(), self.create_valacef_vala(),
            self.create_valacef_c_header(),  self.create_valacef_c_code())

    def resolve_struct_parents(self):
        """Resolve inheritance of structs."""
        # Structs can inherit only from base classes or base structs.
        # They are then the very first struct members, albeit implicit in Vala struct definition.
        for struct in self.repo.structs.values():
            if struct.c_name in self.base_classes:
                struct.set_is_class(True)
            else:
                parent_type = self.repo.resolve_c_type(struct.members[0].c_type)
                if parent_type.c_name in self.base_structs or parent_type.c_name in self.base_classes:
                    struct.set_parent(parent_type)
                    struct.members.pop(0)
                    if parent_type.c_name in self.base_classes:
                        struct.set_is_class(True)

    def wrap_simple_classes(self):
        """Wrap ref-counted simple classes."""
        # Base ref-counted classes are abstract because it is necessary to set up reference counting.
        # Wrapper classes do that in their public constructor.
        klasses = []
        for struct in self.repo.structs.values():
            if struct.is_class and struct.c_name not in self.base_classes:
                wrapped_name = struct.vala_name + "Ref"
                wrapped_c_name = 'Cef' + wrapped_name
                members = [
                    StructMember("GData*", "private_data", "private_data"),
                    StructMember("volatile int", "ref_count", "ref_count")
                ]

                # Vala definition
                klass = Struct(
                    c_name=wrapped_c_name,
                    vala_name=wrapped_name,
                    c_header="valacef_api.h",
                    members=members)
                klass.set_parent(struct)
                klass.set_is_class(True)
                construct = Function(
                    c_name=wrapped_c_name + "New",
                    vala_name=wrapped_name,
                    c_header="valacef_api.h")
                construct.construct = True
                klass.add_method(construct)

                priv_set = Function(
                    c_name=wrapped_c_name + "PrivSet",
                    vala_name="priv_set",
                    c_header="valacef_api.h",
                    params=[
                        ("const char*", "key"),
                        ("T", "data"),
                    ],
                    vala_generics=["T"],
                    vala_simple_generics=True
                )
                klass.add_method(priv_set)
                priv_get = Function(
                    c_name=wrapped_c_name + "PrivGet",
                    vala_name="priv_get",
                    c_header="valacef_api.h",
                    params=[
                        ("const char*", "key"),
                    ],
                    ret_type="T",
                    vala_generics=["T"],
                    vala_simple_generics=True
                )
                klass.add_method(priv_get)
                klass.add_method(Function(
                    c_name=wrapped_c_name + "PrivDel",
                    vala_name="priv_del",
                    c_header="valacef_api.h",
                    params=[
                        ("const char*", "key"),
                    ],
                ))

                klasses.append(klass)

                # C definition
                c_klass = Struct(
                    c_name=wrapped_c_name,
                    vala_name=wrapped_name,
                    c_header="stdlib.h;capi/cef_base_capi.h",
                    members=members)
                c_klass.set_parent(struct)
                c_klass.set_is_class(True)
                construct = Function(wrapped_c_name + "New", wrapped_name, "", wrapped_c_name + '*', body=[
                    '%s* self = (%s*) calloc(1, sizeof(%s));' % (wrapped_c_name, wrapped_c_name, wrapped_c_name),
                    '%s((void*) self, sizeof(%s), sizeof(%s));' % (
                        'cef_base_ref_counted_init_ref_counting', struct.c_name, wrapped_c_name),
                    'g_datalist_init(&(self->private_data));',
                    'return self;'
                ])
                construct.construct = True
                c_klass.add_method(construct)

                priv_set = Function(wrapped_c_name + "PrivSet", "priv_set", "", params=[
                        (wrapped_c_name + "*", "self"),
                        ("const char*", "key"),
                        ("void*", "data"),
                        ('GDestroyNotify', 'destroy'),
                    ],
                    body=[
                        'g_assert (self != NULL);',
                        'g_assert (key != NULL);',
                        'g_datalist_id_set_data_full(',
                        '&self->private_data, g_quark_from_string(key), data, data ? destroy : (GDestroyNotify) NULL);',
                ])
                c_klass.add_method(priv_set)
                priv_get = Function(wrapped_c_name + "PrivGet", "priv_get", "", params=[
                        (wrapped_c_name + "*", "self"),
                        ("const char*", "key"),
                    ],
                    ret_type="void*",
                    body=[
                        'g_assert (self != NULL);',
                        'g_assert (key != NULL);',
                        'return g_datalist_get_data(&self->private_data, key);',
                ])
                c_klass.add_method(priv_get)
                c_klass.add_method(Function(wrapped_c_name + "PrivDel", "priv_del", "", params=[
                        (wrapped_c_name + "*", "self"),
                        ("const char*", "key"),
                    ],
                    body=[
                        'g_return_if_fail (self != NULL);',
                        'g_return_if_fail (key != NULL);',
                        'g_datalist_remove_data(&self->private_data, key);',
                ]))
                self.add_c_glue(c_klass)

        self.repo.add_struct(*klasses)

    def create_valacef_vapi(self) -> str:
        return "".join(self.repo.gen_vala_code())

    def create_valacef_vala(self) -> str:
        buf = ['namespace Cef {']
        for entry in self.vala_glue:
            for line in entry.gen_vala_code(self.repo):
                buf.extend(('    ', line, '\n'))
        buf.append('}')
        return "".join(buf)

    def create_valacef_c_header(self) -> str:
        buf = ['#ifndef VALACEF_H\n#define VALACEF_H\n\n']
        for entry in self.c_glue:
            for line in entry.gen_c_header(self.repo):
                buf.extend((line, '\n'))
        buf.append('\n#endif\n')
        return "".join(buf)

    def create_valacef_c_code(self) -> str:
        buf = ['#include <glib.h>\n']
        for entry in self.c_glue:
            for line in entry.gen_c_code(self.repo):
                buf.extend((line, '\n'))
        return "".join(buf)
