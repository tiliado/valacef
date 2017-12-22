from collections import namedtuple
from itertools import chain
from typing import List, Dict, Tuple, Any

from valacefgen import utils
from valacefgen.vala import VALA_TYPES, VALA_ALIASES, GLIB_TYPES

TypeInfo = utils.TypeInfo
EnumValue = namedtuple("EnumValue", 'c_name vala_name comment')


class Type:
    def __init__(self, c_name: str, vala_name: str, c_header: str, comment: str = None):
        self.comment = utils.reformat_comment(comment)
        self.c_name = c_name
        self.vala_name = vala_name
        self.c_header = c_header

    def is_simple_type(self, repo: "Repository") -> bool:
        raise NotImplementedError

    def gen_vala_code(self, repo: "Repository") -> List[str]:
        raise NotImplementedError


class SimpleType(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, comment: str = None):
        super().__init__(c_name, vala_name, c_header, comment)

    def gen_vala_code(self, repo: "Repository") -> List[str]:
        return []

    def is_simple_type(self, repo: "Repository") -> bool:
        return True


class Enum(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, values: List[EnumValue], comment: str = None):
        super().__init__(c_name, vala_name, c_header, comment)
        self.values = values

    def is_simple_type(self, repo: "Repository") -> bool:
        return True

    def __repr__(self):
        return "enum %s" % self.vala_name

    def gen_vala_code(self, repo: "Repository") -> List[str]:
        buf = []
        if self.comment:
            buf.extend(utils.vala_comment(self.comment, valadoc=True))
        buf.extend([
            '[CCode (cname="%s", cheader_filename="%s", has_type_id=false)]' % (self.c_name, self.c_header),
            'public enum %s {' % self.vala_name,
        ])
        n_values = len(self.values)
        for i, value in enumerate(self.values):
            if value.comment:
                buf.extend('    ' + line for line in utils.vala_comment(value.comment, valadoc=True))
            buf.append('    [CCode (cname="%s")]' % value.c_name)
            buf.append('    %s%s' % (value.vala_name, "," if i < n_values - 1 else ";"))
        buf.append('}')
        return buf


class Function(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, ret_type: str = None,
                 params: List[Tuple[str, str]] = None, body: List[str] = None, comment: str = None,
                 vala_generics: List[str] = None, vala_simple_generics: bool = False):
        super().__init__(c_name, vala_name, c_header, comment)
        self.vala_simple_generics = vala_simple_generics
        self.vala_generics = vala_generics
        self.params = params
        self.ret_type = ret_type if ret_type != 'void' else None
        self.body = body
        self.construct = False

    def gen_vala_code(self, repo: "Repository") -> List[str]:
        params = repo.vala_param_list(self.params, self.c_name, generics=self.vala_generics)
        ret_type = repo.vala_ret_type(self.ret_type, generics=self.vala_generics)
        buf = []
        if self.comment:
            buf.extend(utils.vala_comment(self.comment, valadoc=True))

        buf.extend([
            '[CCode (cname="%s", cheader_filename="%s"%s)]' % (
                self.c_name, self.c_header,
                ', simple_generics=true' if self.vala_simple_generics else ''),
            'public %s %s%s(%s)%s' % (
                ret_type if not self.construct else '',
                self.vala_name,
                '<%s>' % (','.join(self.vala_generics),) if self.vala_generics else '',
                ', '.join(params),
                ';' if self.body is None else ' {'
            )
        ])
        if self.body is not None:
            body: List[str] = self.body
            buf.extend('    ' + line for line in body)
            buf.append("}")
        return buf

    def gen_c_header(self, repo: "Repository") -> List[str]:
        return self._gen_c_code(repo, False)

    def gen_c_code(self, repo: "Repository") -> List[str]:
        return self._gen_c_code(repo, True)

    def _gen_c_code(self, repo: "Repository", gen_body: bool) -> List[str]:
        params = repo.c_param_list(self.params)
        ret_type = repo.c_ret_type(self.ret_type)
        buf = []
        if self.c_header:
            buf.extend('#include "%s"' % h for h in self.c_header.split(';'))
        buf.extend([
            '%s %s(%s)%s' % (
                ret_type,
                self.c_name,
                ', '.join(params),
                ';' if not gen_body or self.body is None else ' {'
            )
        ])
        if gen_body and self.body is not None:
            body: List[str] = self.body
            buf.extend('    ' + line for line in body)
            buf.append("}")
        return buf

    def is_simple_type(self, repo: "Repository") -> bool:
        return False


class Struct(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, members: List["StructMember"], comment: str = None,
                 virtual_funcs: List["StructVirtualFunc"] = None):
        super().__init__(c_name, vala_name, c_header, comment)
        self.virtual_funcs = virtual_funcs
        self.members = members
        self.parent: Struct = None
        self.methods: List[Function] = []
        self.is_class: bool = False
        self.ref_func: str = None
        self.unref_func: str = None

    def set_parent(self, parent: "Struct"):
        self.parent = parent

    def set_is_class(self, is_class: bool):
        self.is_class = is_class

    def set_ref_counting(self, ref_func: str, unref_func: str):
        self.ref_func = ref_func
        self.unref_func = unref_func

    def add_method(self, method: Function):
        self.methods.append(method)

    def is_simple_type(self, repo: "Repository") -> bool:
        return False

    def gen_vala_code(self, repo: "Repository") -> List[str]:
        buf = []
        if self.comment:
            buf.extend(utils.vala_comment(self.comment, valadoc=True))
        ccode = {
            'cname': '"%s"' % self.c_name,
            'cheader_filename': '"%s"' % self.c_header,
            'has_type_id': 'false',
        }
        if self.is_class:
            buf.append('[Compact]')
            struct_type = 'class'
            if self.ref_func:
                ccode['ref_function'] = '"%s"' % self.ref_func
            if self.unref_func:
                ccode['unref_function'] = '"%s"' % self.unref_func
        else:
            struct_type = 'struct'
            ccode['destroy_function'] = '""'
        buf.append('[CCode (%s)]' % ', '.join('%s=%s' % e for e in ccode.items()))
        if self.parent:
            buf.append('public %s %s: %s {' % (struct_type, self.vala_name, self.parent.vala_name))
        else:
            buf.append('public %s %s {' % (struct_type, self.vala_name))
        for member in self.members:
            type_info = utils.parse_c_type(member.c_type)
            vala_type = repo.resolve_c_type(type_info.c_type)
            if 'char' in member.c_type:
                print("!!!", member.c_type)
            if member.c_type == 'char*':
                m_type = 'string?'
            elif member.c_type == 'char**':
                m_type = 'char**'
            else:
                m_type = vala_type.vala_name
                if type_info.pointer:
                    m_type += '?'
            if member.comment:
                buf.extend('    ' + line for line in utils.vala_comment(member.comment, valadoc=True))
            if member.c_name != member.vala_name:
                buf.append('    [CCode (cname="%s")]' % member.c_name)
            buf.append('    public %s %s;' % (m_type, member.vala_name))

        for method in self.methods:
            if method.construct:
                break
        else:
            buf.append('    protected %s(){}' % self.vala_name)
        for method in self.methods:
            buf.extend('    ' + line for line in method.gen_vala_code(repo))
        for vfunc in self.virtual_funcs or []:
            params = repo.vala_param_list(vfunc.params, vfunc_of_class=self.c_name)
            ret_type = repo.vala_ret_type(vfunc.ret_type)
            if ret_type == "StringUserfree":
                ret_type = "string?"
            if vfunc.comment:
                buf.extend('    ' + line for line in utils.vala_comment(vfunc.comment, valadoc=True))
            buf.extend([
                '    [CCode (cname="%s", cheader_filename="valacef_api.h")]' % vfunc.c_name,
                '    public %s %s(%s);' % (ret_type, vfunc.vala_name, ', '.join(params[1:])),
            ])
        buf.append('}')
        return buf

    def gen_c_header(self, repo: "Repository") -> List[str]:
        return self._gen_c_code(repo, 'gen_c_header')

    def gen_c_code(self, repo: "Repository") -> List[str]:
        return self._gen_c_code(repo, 'gen_c_code')

    def _gen_c_code(self, repo: "Repository", generator: str) -> List[str]:
        buf = [
            '#include "%s"' % self.parent.c_header,
        ]
        if self.c_header:
            buf.extend('#include "%s"' % h for h in self.c_header.split(';'))
        buf.extend([
            'typedef struct {',
            '    %s parent;' % self.parent.c_name,
        ])

        for member in self.members:
            type_info = utils.parse_c_type(member.c_type)
            vala_type = repo.resolve_c_type(type_info.c_type)
            buf.append('    %s%s %s;' % ('volatile ' if type_info.volatile else '', vala_type.c_name, member.c_name))
        buf.append('} %s;' % self.c_name)
        for method in self.methods:
            buf.extend('    ' + line for line in getattr(method, generator)(repo))
        return buf


class StructMember:
    def __init__(self, c_type: str, c_name: str, vala_name: str, comment: str = None):
        self.comment = utils.reformat_comment(comment, strip_chars=5)
        self.c_type = c_type
        self.c_name = c_name
        self.vala_name = vala_name


class StructVirtualFunc:
    def __init__(self, c_name: str, vala_name: str, ret_type: str = None, params: List[Tuple[str, str]] = None,
                 comment: str = None):
        self.comment = utils.reformat_comment(comment, strip_chars=5)
        self.c_name = c_name
        self.vala_name = vala_name
        self.ret_type = ret_type if ret_type != 'void' else None
        self.params = params


class Typedef(Type):
    def __init__(self, c_name: str, vala_name: str, c_type: str, c_header: str):
        super().__init__(c_name, vala_name, c_header)
        self.c_type = c_type

    def is_simple_type(self, repo: "Repository") -> bool:
        c_type = self.c_type
        if c_type in VALA_TYPES or c_type in VALA_ALIASES:
            return True
        return repo.c_types[c_type].is_simple_type(repo)

    def gen_vala_code(self, repo: "Repository") -> List[str]:
        buf = []
        c_type = self.c_type
        if c_type != 'void*':
            simple_type = self.is_simple_type(repo)
            if c_type in VALA_TYPES:
                base_type = c_type
            elif c_type in VALA_ALIASES:
                base_type = VALA_ALIASES[c_type]
            else:
                c_type_obj = repo.c_types[c_type]
                base_type = c_type_obj.vala_name
            if simple_type:
                buf.append('[SimpleType]')
            buf.append('[CCode (cname="%s", has_type_id=false)]' % self.c_name)
            buf.append('public struct %s : %s {' % (self.vala_name, base_type))
            buf.append('}')
        else:
            buf.append('[CCode (cname="%s", has_type_id=false)]' % self.c_name)
            buf.append('public struct %s{' % self.vala_name)
            buf.append('}')
        return buf


class Delegate(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, ret_type: str = None,
                 params: List[Tuple[str, str]] = None, vfunc_of_class=None, vfunc_name=None):
        super().__init__(c_name, vala_name, c_header)
        self.vfunc_name = vfunc_name
        self.ret_type = ret_type if ret_type != 'void' else None
        self.params = params
        self.vfunc_of_class = vfunc_of_class

    def gen_vala_code(self, repo: "Repository") -> List[str]:
        params = repo.vala_param_list(self.params, vfunc_of_class=self.vfunc_of_class)
        ret_type = repo.vala_ret_type(self.ret_type)
        buf = [
            '[CCode (cname="%s", cheader_filename="%s", has_target = false)]' % (
                self.c_name, self.c_header),
            'public delegate %s %s(%s);' % (ret_type, self.vala_name, ', '.join(params)),
        ]
        return buf

    def _gen_c_code(self, repo: "Repository", body: bool) -> List[str]:
        params = repo.c_param_list(self.params)
        ret_type = repo.c_ret_type(self.ret_type)
        buf = []
        if self.c_header:
            buf.extend('#include "%s"' % h for h in self.c_header.split(';'))
        if self.ret_type:
            header = repo.resolve_c_type(utils.parse_c_type(ret_type).c_type).c_header
            if header:
                buf.append('#include "%s"' % header)
        if self.params:
            headers = (repo.resolve_c_type(utils.parse_c_type(h[0]).c_type).c_header for h in self.params)
            buf.extend('#include "%s"' % h for h in headers if h)
        buf.extend([
            'typedef %s (*%s)(%s);' % (
                ret_type,
                self.c_name,
                ', '.join(params)
            )
        ])
        if self.vfunc_name:
            buf.extend([
                '%s %s_%s(%s)%s' % (
                    ret_type if ret_type != 'cef_string_userfree_t' else 'char*',
                    self.vfunc_of_class,
                    self.vfunc_name,
                    ', '.join(params),
                    ' {' if body else ';'
                )
            ])
            if body:
                call = 'self->%s(%s);' % (self.vfunc_name, ', '.join(p[1] for p in self.params))
                if ret_type == 'void':
                    buf.append('    ' + call)
                elif ret_type == 'cef_string_userfree_t':
                    buf.extend([
                        '    %s __utf16_str__ = %s' % (ret_type, call),
                        '    if (__utf16_str__ == NULL) return NULL;',
                        '    cef_string_utf8_t __utf8_str__ = {};',
                        '    cef_string_utf16_to_utf8(__utf16_str__->str, __utf16_str__->length, &__utf8_str__);',
                        '    cef_string_userfree_free(__utf16_str__);',
                        '    return __utf8_str__.str;'
                    ])
                else:
                    buf.append('    return ' + call)
                buf.append('}')
        return buf

    def gen_c_code(self, repo: "Repository") -> List[str]:
        return self._gen_c_code(repo, True)

    def gen_c_header(self, repo: "Repository") -> List[str]:
        return self._gen_c_code(repo, False)

    def is_simple_type(self, repo: "Repository") -> bool:
        return True


class Repository:
    enums: Dict[str, Enum]
    structs: Dict[str, Struct]
    typedefs: Dict[str, Typedef]
    c_types: Dict[str, Type]

    def __init__(self, vala_namespace: str, overrides: Any = None):
        self.overrides = overrides
        self.vala_namespace = vala_namespace
        self.enums: Dict[str, Enum] = {}
        self.structs: Dict[str, Struct] = {}
        self.typedefs: Dict[str, Typedef] = {}
        self.delegates: Dict[str, Delegate] = {}
        self.functions: Dict[str, Function] = {}
        self.c_types: Dict[str, Type] = {}

    def add_enum(self, enum: Enum):
        self.enums[enum.c_name] = enum
        self.c_types[enum.c_name] = enum

    def add_struct(self, *structs: Struct):
        for struct in structs:
            self.structs[struct.c_name] = struct
            self.c_types[struct.c_name] = struct

    def add_typedef(self, typedef: Typedef):
        self.typedefs[typedef.c_name] = typedef
        self.c_types[typedef.c_name] = typedef

    def add_delegate(self, delegate: Delegate):
        self.delegates[delegate.c_name or delegate.vala_name] = delegate
        self.c_types[delegate.c_name or delegate.vala_name] = delegate

    def add_function(self, *functions: Function):
        for func in functions:
            self.functions[func.c_name] = func
            self.c_types[func.c_name] = func

    def resolve_c_type(self, c_type: str) -> Type:
        c_type = utils.bare_c_type(c_type)
        if c_type in VALA_TYPES:
            return SimpleType(c_type, c_type, "")
        if c_type in VALA_ALIASES:
            return self.resolve_c_type(VALA_ALIASES[c_type])
        if c_type in GLIB_TYPES:
            return SimpleType(c_type + "*", GLIB_TYPES[c_type], "")
        try:
            return self.c_types[c_type]
        except KeyError:
            raise NotImplementedError(c_type)

    def __repr__(self):
        buf = []
        for enum in self.enums.values():
            buf.append(repr(enum))
        return '\n'.join(buf)

    def gen_vala_code(self):
        buf = ['namespace %s {\n' % self.vala_namespace]
        entries = self.enums, self.delegates, self.functions, self.typedefs, self.structs
        for entry in chain.from_iterable(e.values() for e in entries):
            for line in entry.gen_vala_code(self):
                buf.extend(('    ', line, '\n'))
        buf.append('} // namespace %s\n' % self.vala_namespace)
        return ''.join(buf)

    def c_ret_type(self, c_type: str = None) -> str:
        return c_type if c_type else 'void'

    def vala_ret_type(self, c_type: str = None, generics: List[str] = None) -> str:
        if generics and c_type in generics:
            return "unowned " + c_type
        if c_type == 'char*':
            return 'string?'
        if c_type is None:
            return "void"
        type_info = utils.parse_c_type(c_type)

        ret_type = self.resolve_c_type(type_info.c_type).vala_name
        if type_info.pointer:
            ret_type += "?"
        return ret_type

    def vala_param_list(self, params: List[Tuple[str, str]] = None, name: str = None, vfunc_of_class: str = None,
                        generics: List[str] = None) -> List[str]:
        vala_params = []
        if params is not None:
            for p_type, p_name in params:
                if generics and p_type in generics:
                    param = "owned " + p_type
                else:
                    type_info = utils.parse_c_type(p_type)
                    if name:
                        self.override_param(name, p_name, type_info)
                    param = ""
                    if type_info.ref:
                        param += 'ref '
                    elif type_info.out:
                        param += 'out '
                    else:
                        try:
                            # CEF reference counting: When passing a struct to delegate/function,
                            # increase ref unless it is a self-param of vfunc of that struct.
                            if self.structs[type_info.c_type].is_class and type_info.c_type != vfunc_of_class:
                                param += "owned "
                        except KeyError:
                            pass

                    vala_type = self.resolve_c_type(type_info.c_type).vala_name
                    if vala_type == 'String' and type_info.pointer:
                        param += '' + vala_type + '*'
                    elif vala_type == 'char' and type_info.pointer:
                        param += 'string?'
                    else:
                        param += vala_type
                        if type_info.pointer:
                            param += "?"
                param += ' ' + p_name
                vala_params.append(param)
        return vala_params

    def c_param_list(self, params: List[Tuple[str, str]] = None) -> List[str]:
        c_params = []
        if params is not None:
            for p_type, p_name in params:
                c_params.append('%s %s' % (p_type, p_name))
        return c_params

    def override_param(self, name: str, p_name: str, type_info: TypeInfo) -> TypeInfo:
        try:
            return getattr(self.overrides, 'param__%s__%s' % (name, p_name))(type_info)
        except AttributeError as e:
            return type_info
