typedef struct _cef_string_utf8_t {
  char* str;
  size_t length;
  void (*dtor)(char* str);
} cef_string_utf8_t;

typedef struct _cef_string_utf16_t {
  char16* str;
  size_t length;
  void (*dtor)(char16* str);
} cef_string_utf16_t;


///
// These functions convert between UTF-8, -16, and -32 strings. They are
// potentially slow so unnecessary conversions should be avoided. The best
// possible result will always be written to |output| with the boolean return
// value indicating whether the conversion is 100% valid.
///
int cef_string_utf8_to_utf16(const char* src, size_t src_len, cef_string_t* output);

///
// These functions convert between UTF-8, -16, and -32 strings. They are
// potentially slow so unnecessary conversions should be avoided. The best
// possible result will always be written to |output| with the boolean return
// value indicating whether the conversion is 100% valid.
///
int cef_string_utf16_to_utf8(const char16* src, size_t src_len, cef_string_utf8_t* output);

///
// These functions set string values. If |copy| is true (1) the value will be
// copied instead of referenced. It is up to the user to properly manage
// the lifespan of references.
///
int cef_string_utf16_set(const char16* src, size_t src_len, cef_string_utf16_t* output, int copy);

///
// Convenience macros for copying values.
///
int cef_string_utf16_copy(const char16* src, size_t src_len, cef_string_utf16_t* output);

///
// These functions clear string values. The structure itself is not freed.
///
void cef_string_utf16_clear(cef_string_utf16_t* str);

///
// These functions free the string structure allocated by the associated
// alloc function. Any string contents will first be cleared.
///
void cef_string_userfree_utf16_free(cef_string_userfree_utf16_t str);
