from collections import namedtuple
from itertools import chain
from typing import List, Dict

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


class Struct(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str):
        super().__init__(c_name, vala_name, c_header)

    def is_simple_type(self, repo: "Repository") -> bool:
        return False

    def __vala__(self, repo: "Repository") -> List[str]:
        buf = [
            '[CCode (cname="%s", cheader_file="%s")]' % (self.c_name, self.c_header),
            'public struct %s {' % self.vala_name,
        ]
        buf.append('}')
        return buf


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
        self.c_types: Dict[str, Type] = {}

    def add_enum(self, enum: Enum):
        self.enums[enum.c_name] = enum
        self.c_types[enum.c_name] = enum

    def add_struct(self, struct: Struct):
        self.enums[struct.c_name] = struct
        self.c_types[struct.c_name] = struct

    def add_typedef(self, typedef: Typedef):
        self.typedefs[typedef.c_name] = typedef
        self.c_types[typedef.c_name] = typedef

    def __repr__(self):
        buf = []
        for enum in self.enums.values():
            buf.append(repr(enum))
        return '\n'.join(buf)

    def __vala__(self):
        buf = ['namespace %s {\n' % self.vala_namespace]
        entries = self.enums, self.typedefs, self.structs
        for entry in chain.from_iterable(e.values() for e in entries):
            for line in entry.__vala__(self):
                buf.extend(('    ', line, '\n'))
        buf.append('} // namespace %s\n' % self.vala_namespace)
        return ''.join(buf)
