from cefpyum.cpp_cef_types cimport cef_string_t
from cefpyum.cpp_cef_primitives cimport char16
from cefpyum.cpp_cef_string cimport cef_string_utf8_t

cdef extern from "capi/cef_base_capi.h":
    cdef int cef_string_utf8_to_utf16(const char* src, size_t src_len, cef_string_t* output)
    cdef int cef_string_utf16_to_utf8(const char16* src, size_t src_len, cef_string_utf8_t* output);
