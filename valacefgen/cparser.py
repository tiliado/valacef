from CppHeaderParser import CppHeader

from valacefgen.types import Repository, EnumValue, Enum, Struct
from valacefgen.utils import find_prefix, lstrip, rstrip, camel_case


class Naming:
    def __init__(self, strip_prefix: str):
        self.strip_prefix = strip_prefix

    def enum(self, name):
        return camel_case(rstrip(lstrip(name, self.strip_prefix.lower() + "_"), '_t'))

    def struct(self, name):
        return camel_case(rstrip(lstrip(name, self.strip_prefix.lower() + "_"), '_t'))


class Parser:
    def __init__(self, naming: Naming, repo: Repository):
        self.naming = naming
        self.repo = repo

    def parse_header(self, path: str, c_include_path: str):
        with open(path) as f:
            data = f.read().replace('CEF_EXPORT', '').replace('CEF_CALLBACK', '')
        header = CppHeader(data, 'string')
        self.parse_enums(c_include_path, header.enums)
        self.parse_structs(c_include_path, header.classes)

    def parse_enums(self, c_include_path: str, enums):
        for enum in enums:
            if enum['typedef']:
                name = enum['name']
                values = [v['name'] for v in enum['values']]
                n_prefix = len(find_prefix(values))
                values = [EnumValue(v, v[n_prefix:]) for v in values]
                self.repo.add_enum(Enum(name, self.naming.enum(name), c_include_path, values))
            else:
                raise NotImplementedError

    def parse_structs(self, c_include_path: str, structs):
        for name, klass in structs.items():
            self.parse_struct(c_include_path, name, klass)

    def parse_struct(self, c_include_path: str, name: str, klass):
        inherits = klass['inherits']
        methods = klass['methods']
        properties = klass['properties']
        if klass['declaration_method'] == 'class':
            raise NotImplementedError(name)

        self.repo.add_struct(Struct(name, self.naming.struct(name), c_include_path))
