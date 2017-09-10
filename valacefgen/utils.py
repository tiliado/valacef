from collections import namedtuple
from typing import List, Tuple, Iterable, Optional


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
    return c_type.replace('const*', '*').replace('const *', '*').replace(' *', '*')


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


class TypeInfo:
    def __init__(self, c_type: str, pointer: bool = False, const: bool = False, volatile: bool = False,
                 ref: bool = False, out: bool = False):
        self.c_type = c_type
        self.pointer = pointer
        self.const = const
        self.volatile = volatile
        self.ref = ref
        self.out = out


def parse_c_type(c_type: str) -> TypeInfo:
    const = c_type.startswith('const ')
    c_type = lstrip(c_type, 'const ')
    volatile = c_type.startswith('volatile ')
    c_type = lstrip(c_type, 'volatile ')
    c_type = correct_c_type(c_type)
    if c_type in ('void*', 'void**'):
        return TypeInfo(c_type, False, const, volatile, False, False)
    pointer = c_type.endswith('*')
    c_type = c_type.rstrip('*')

    c_type = lstrip(c_type, 'struct _')
    return TypeInfo(c_type, pointer, const, volatile, False, False)


def vala_comment(lines: Iterable[str], valadoc: bool = False) -> Iterable[str]:
    yield '/*' if not valadoc else '/**'
    for line in lines:
        yield ' * ' + line
    yield ' */'


def reformat_comment(comment: Optional[str], strip_chars=3) -> Optional[str]:
    return [line[strip_chars:] for line in comment.splitlines(False)[1:-1]] if comment else None
