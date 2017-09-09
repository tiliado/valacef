from libc.stdlib cimport malloc, free
from libc.string cimport strncpy
from cefpyum.cpp_cef_types_linux cimport cef_main_args_t
from cpython.bytes cimport PyBytes_AsString, PyBytes_Size

cdef class MainArgs:
    cdef cef_main_args_t c_struct

    def __cinit__(self):
        self.c_struct.argv = NULL
        self.c_struct.argc = 0

    def __dealloc__(self):
        for i in range(self.c_struct.argc):
            free(self.c_struct.argv[i])
        if self.c_struct.argv is not NULL:
            free(self.c_struct.argv)
        self.c_struct.argv = NULL
        self.c_struct.argc = 0

    def __init__(self, argv, *_args, **_kwargs):
        super().__init__(*_args, **_kwargs)
        self.set_argv(argv)

    cdef cef_main_args_t* get_c_struct(self):
        return &self.c_struct

    def get_argc(self):
        return self.c_struct.argc

    def set_argv(self, list argv):
        cdef char* string
        cdef int string_size
        cdef int size = len(argv)
        cdef char **_argv = <char**> malloc(size * sizeof(char*))
        for i in range(size):
            string_size = PyBytes_Size(argv[i])
            string = <char*> malloc(string_size * sizeof(char))
            strncpy(string, PyBytes_AsString(argv[i]), string_size)
            _argv[i] = string
        self.c_struct.argv = _argv
        self.c_struct.argc = size

