from collections import namedtuple
from typing import List, Dict


EnumValue = namedtuple("EnumValue", 'c_name vala_name')


class Type:
    pass


class Enum(Type):
    def __init__(self, c_name: str, vala_name: str, c_header: str, values: List[EnumValue]):
        self.values = values
        self.c_name = c_name
        self.vala_name = vala_name
        self.c_header = c_header

    def __repr__(self):
        return "enum %s" % self.vala_name

    def __vala__(self) -> List[str]:
        buf = [
            '[CCode (cname="%s", cheader_file="%s")]' % (self.c_name, self.c_header),
            'public enum %s {' % self.vala_name,
        ]
        n_values = len(self.values)
        for i, value in enumerate(self.values):
            buf.append('    [CCode (cname="%s")]' % value.c_name)
            buf.append('    %s%s' % (value.vala_name, "," if i < n_values - 1 else ";"))
        buf.append('}')
        return buf


class Struct:
    def __init__(self, c_name: str, vala_name: str, c_header: str):
        self.c_header = c_header
        self.c_name = c_name
        self.vala_name = vala_name

    def __vala__(self) -> List[str]:
        buf = [
            '[CCode (cname="%s", cheader_file="%s")]' % (self.c_name, self.c_header),
            'public struct %s {' % self.vala_name,
        ]
        buf.append('}')
        return buf


class Repository:
    enums: Dict[str, Enum]
    structs: Dict[str, Struct]
    c_types: Dict[str, Type]

    def __init__(self):
        self.enums = {}
        self.structs = {}
        self.c_types = {}

    def add_enum(self, enum: Enum):
        self.enums[enum.c_name] = enum
        self.c_types[enum.c_name] = enum

    def add_struct(self, struct: Struct):
        self.enums[struct.c_name] = struct
        self.c_types[struct.c_name] = struct

    def __repr__(self):
        buf = []
        for enum in self.enums.values():
            buf.append(repr(enum))
        return '\n'.join(buf)

    def __vala__(self):
        buf = []
        for entry in self.enums.values():
            buf.extend(entry.__vala__())
        for entry in self.structs.values():
            buf.extend(entry.__vala__())
        return '\n'.join(buf)
