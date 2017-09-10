from typing import List


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
    return c_type if c_type == 'void*' else c_type.rstrip('*')
