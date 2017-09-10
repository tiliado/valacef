from collections import namedtuple
from itertools import chain
from typing import List, Dict, Tuple

from valacefgen import utils
from valacefgen.vala import VALA_TYPES, VALA_ALIASES

EnumValue = namedtuple("EnumValue", 'c_name vala_name')


class Type:
    def __init__(self, c_name: str, vala_name: str, c_header: str):
        self.c_name = c_name
        self.vala_name = vala_name
        self.c_header = c_header

    def is_simple_type(self, repo: "Repository") -> bool:
        raise NotImplementedError

    def __vala__(self, repo: "Repository") -> List[str]:
        raise NotImplementedError


class SimpleType(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str):
        super().__init__(c_name, vala_name, c_header)

    def __vala__(self, repo: "Repository") -> List[str]:
        return []

    def is_simple_type(self, repo: "Repository") -> bool:
        return True


class Enum(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, values: List[EnumValue]):
        super().__init__(c_name, vala_name, c_header)
        self.values = values

    def is_simple_type(self, repo: "Repository") -> bool:
        return True

    def __repr__(self):
        return "enum %s" % self.vala_name

    def __vala__(self, repo: "Repository") -> List[str]:
        buf = [
            '[CCode (cname="%s", cheader_file="%s", has_type_id=false)]' % (self.c_name, self.c_header),
            'public enum %s {' % self.vala_name,
        ]
        n_values = len(self.values)
        for i, value in enumerate(self.values):
            buf.append('    [CCode (cname="%s")]' % value.c_name)
            buf.append('    %s%s' % (value.vala_name, "," if i < n_values - 1 else ";"))
        buf.append('}')
        return buf


class Function(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, ret_type: str = None,
                 params: List[Tuple[str, str]] = None, body: List[str] = None):
        super().__init__(c_name, vala_name, c_header)
        self.params = params
        self.ret_type = ret_type
        self.body = body

    def __vala__(self, repo: "Repository") -> List[str]:
        params = repo.vala_param_list(self.params)
        ret_type = repo.vala_ret_type(self.ret_type)
        buf = [
            '[CCode (cname="%s")]' % self.c_name,
            'public %s %s(%s)%s' % (
                ret_type,
                self.vala_name,
                ', '.join(params),
                ';' if self.body is None else ' {'
            )
        ]
        if self.body is not None:
            body: List[str] = self.body
            buf.extend('    ' + line for line in body)
            buf.append("}")
        return buf

    def is_simple_type(self, repo: "Repository") -> bool:
        return False


class Struct(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, members: List["StructMember"]):
        super().__init__(c_name, vala_name, c_header)
        self.members = members
        self.parent: Struct = None
        self.methods: List[Function] = []

    def set_parent(self, parent: "Struct"):
        self.parent = parent

    def add_method(self, method: Function):
        self.methods.append(method)

    def is_simple_type(self, repo: "Repository") -> bool:
        return False

    def __vala__(self, repo: "Repository") -> List[str]:
        buf = [
            '[CCode (cname="%s", cheader_file="%s", has_type_id=false, destroy_function="")]' % (
                self.c_name, self.c_header),
        ]
        if self.parent:
            buf.append('public struct %s: %s {' % (self.vala_name, self.parent.vala_name))
        else:
            buf.append('public struct %s {' % self.vala_name)
        for member in self.members:
            vala_type = repo.resolve_c_type(member.c_type)
            buf.append('    public %s %s;' % (vala_type.vala_name, member.vala_name))

        for method in self.methods:
            buf.extend('    ' + line for line in method.__vala__(repo))
        buf.append('}')
        return buf


class StructMember:
    def __init__(self, c_type: str, c_name: str, vala_name: str):
        self.c_type = c_type
        self.c_name = c_name
        self.vala_name = vala_name


class Typedef(Type):
    def __init__(self, c_name: str, vala_name: str, c_type: str, c_header: str):
        super().__init__(c_name, vala_name, c_header)
        self.c_type = c_type

    def is_simple_type(self, repo: "Repository") -> bool:
        c_type = self.c_type
        if c_type in VALA_TYPES or c_type in VALA_ALIASES:
            return True
        return repo.c_types[c_type].is_simple_type(repo)

    def __vala__(self, repo: "Repository") -> List[str]:
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
        return buf


class Delegate(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, ret_type: str = None,
                 params: List[Tuple[str, str]] = None):
        super().__init__(c_name, vala_name, c_header)
        self.ret_type = ret_type
        self.params = params

    def __vala__(self, repo: "Repository") -> List[str]:
        params = repo.vala_param_list(self.params)
        ret_type = repo.vala_ret_type(self.ret_type)
        buf = [
            '[CCode (cname="%s", cheader_file="%s", has_target = false)]' % (
                self.c_name, self.c_header),
            'public delegate %s %s(%s);' % (ret_type, self.vala_name, ', '.join(params)),
        ]
        return buf

    def is_simple_type(self, repo: "Repository") -> bool:
        return True


class Repository:
    enums: Dict[str, Enum]
    structs: Dict[str, Struct]
    typedefs: Dict[str, Typedef]
    c_types: Dict[str, Type]

    def __init__(self, vala_namespace: str):
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

    def add_struct(self, struct: Struct):
        self.structs[struct.c_name] = struct
        self.c_types[struct.c_name] = struct

    def add_typedef(self, typedef: Typedef):
        self.typedefs[typedef.c_name] = typedef
        self.c_types[typedef.c_name] = typedef

    def add_delegate(self, delegate: Delegate):
        self.delegates[delegate.c_name or delegate.vala_name] = delegate
        self.c_types[delegate.c_name or delegate.vala_name] = delegate

    def add_function(self, func: Function):
        self.functions[func.c_name] = func
        self.c_types[func.c_name] = func

    def resolve_c_type(self, c_type: str) -> Type:
        c_type = utils.bare_c_type(c_type)
        if c_type in VALA_TYPES:
            return SimpleType(c_type, c_type, "")
        if c_type in VALA_ALIASES:
            return self.resolve_c_type(VALA_ALIASES[c_type])
        try:
            return self.c_types[c_type]
        except KeyError:
            raise NotImplemented(c_type)

    def __repr__(self):
        buf = []
        for enum in self.enums.values():
            buf.append(repr(enum))
        return '\n'.join(buf)

    def __vala__(self):
        buf = ['namespace %s {\n' % self.vala_namespace]
        entries = self.enums, self.delegates, self.functions, self.typedefs, self.structs
        for entry in chain.from_iterable(e.values() for e in entries):
            for line in entry.__vala__(self):
                buf.extend(('    ', line, '\n'))
        buf.append('} // namespace %s\n' % self.vala_namespace)
        return ''.join(buf)

    def vala_ret_type(self, c_type: str = None) -> str:
        if c_type is None:
            return "void"
        type_info = utils.parse_c_type(c_type)
        ret_type = self.resolve_c_type(type_info.c_type).vala_name
        if type_info.pointer:
            ret_type += "?"
        return ret_type

    def vala_param_list(self, params: List[Tuple[str, str]] = None) -> List[str]:
        vala_params = []
        if params is not None:
            for p_type, p_name in params:
                type_info = utils.parse_c_type(p_type)
                param = self.resolve_c_type(type_info.c_type).vala_name
                if type_info.pointer:
                    param += "?"
                param += ' ' + p_name
                vala_params.append(param)
        return vala_params
