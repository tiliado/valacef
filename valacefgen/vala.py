VALUE_TYPES = {
    'short', 'int', 'long',
    'uchar', 'ushort', 'uint', 'ulong',
    'bool', 'float', 'double', 'size_t',
    'uint8', 'int8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64',
}


VALA_TYPES = VALUE_TYPES | {
    'char', 'string', 'void*', 'void**', 'time_t',
}


VALA_ALIASES = {
    'unsigned int': 'uint',
    'short unsigned int': 'ushort',
    'unsigned long': 'ulong',
    'int64_t': 'int64',
    'uint64_t': 'uint64',
    'long long': 'int64',
}

GLIB_TYPES = {
    "GData": "GLib.Datalist",
}
