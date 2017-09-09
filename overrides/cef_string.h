/* template <class T>
class CefStringBase {
 public:

  CefStringBase() : CefStringBase(NULL);
  CefStringBase(const CefStringBase& str);
  CefStringBase(const std::string& src);
  CefStringBase(const char* src);
  CefStringBase(const char* src, size_t src_len, bool copy);

  const char* c_str();
  size_t length() const;
  bool empty() const;
  int compare(const CefStringBase& str);
  void clear();
  bool IsOwner() const;
  void ClearAndFree();
  bool FromString(const char* src, size_t src_len, bool copy);
  bool FromASCII(const char* str);
  std::string ToString() const;
  bool FromString(const std::string& str);

  bool operator<(const CefStringBase& str) const;
  bool operator<=(const CefStringBase& str) const;
  bool operator>(const CefStringBase& str) const;
  bool operator>=(const CefStringBase& str) const;
  bool operator==(const CefStringBase& str) const;
  bool operator!=(const CefStringBase& str) const;

  CefStringBase& operator=(const CefStringBase& str);
  operator std::string() const;
//  CefStringBase& operator=(std::string& str);
  CefStringBase& operator=(const char* str);
};

struct CefStringTraitsUTF8 {

};
*/

typedef struct _cef_string_utf8_t {
  char* str;
  size_t length;
  void (*dtor)(char* str);
} cef_string_utf8_t;

//typedef short unsigned int char16

typedef struct _cef_string_utf16_t {
  char16* str;
  size_t length;
  void (*dtor)(char16* str);
} cef_string_utf16_t;
