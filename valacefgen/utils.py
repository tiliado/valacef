from collections import namedtuple
from typing import List, Tuple


def find_prefix(items: List[str]) -> str:
    pos = len(items[0])
    while pos > 0:
        prefix = items[0][0:pos]
        for item in items:
            if not item.startswith(prefix):
                break
        else:
            return prefix
        pos -= 1
    return ""


def lstrip(value, start="") -> str:
    return value if not value.startswith(start) else value[len(start):]


def rstrip(value, end="") -> str:
    return value if not value.endswith(end) else value[:-len(end)]


def camel_case(name: str) -> str:
    return ''.join(s[0].upper() + s[1:] for s in name.split('_'))


def correct_c_type(c_type: str) -> str:
    return c_type.replace(' *', '*')


def bare_c_type(c_type: str) -> str:
    c_type = correct_c_type(c_type)
    return c_type if c_type in ('void*', 'void**') else c_type.rstrip('*')


def is_func_pointer(c_type: str) -> bool:
    return ' ( * ) (' in c_type


def parse_c_func_pointer(c_type: str) -> Tuple[str, List[Tuple[str, str]]]:
    func = c_type.replace(' ( * ) ', '')
    ret_type, params = func.split('(', 1)
    params = [tuple(p.strip().rsplit(None, 1)) for p in params.rsplit(')', 1)[0].split(',')]
    return ret_type, params


TypeInfo = namedtuple("TypeInfo", 'c_type pointer const')


def parse_c_type(c_type: str) -> TypeInfo:
    const = c_type.startswith('const ')
    c_type = lstrip(c_type, 'const ')
    c_type = correct_c_type(c_type)
    if c_type in ('void*', 'void**'):
        return TypeInfo(c_type, False, const)
    pointer = c_type.endswith('*')
    c_type = c_type.rstrip('*')

    c_type = lstrip(c_type, 'struct _')
    return TypeInfo(c_type, pointer, const)

