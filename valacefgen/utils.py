from typing import List


def find_prefix(items: List[str]):
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


def lstrip(value, start=""):
    return value if not value.startswith(start) else value[len(start):]


def rstrip(value, end=""):
    return value if not value.endswith(end) else value[:-len(end)]


def camel_case(name: str):
    return ''.join(s[0].upper() + s[1:] for s in name.split('_'))
