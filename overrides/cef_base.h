/*

template <class T>
class CefRefPtr {
 public:
  // Constructor.  Defaults to initializing with NULL.
  CefRefPtr() : CefRefPtr(NULL);
  // Constructor.  Takes ownership of p.
  explicit CefRefPtr(T* t);

  T& operator*() const;
  T* operator->() const;
};

template <class T>
class CefRawPtr {
 public:
  CefRawPtr() : CefRawPtr(NULL);
  CefRawPtr(T* p);
//  CefRawPtr(const CefRawPtr& r) : ptr_(r.ptr_) {}
  T* get() const;
  T* operator->() const;
  CefRawPtr<T>& operator=(T* p);
  CefRawPtr<T>& operator=(const CefRawPtr<T>& r);
};


*/

//typedef CefStringBase<CefStringTraitsUTF8> CefStringUTF8;
//typedef CefStringUTF8 CefString;




typedef cef_string_utf16_t cef_string_t;
typedef unsigned long cef_window_handle_t;
typedef cef_string_utf16_t* cef_string_userfree_utf16_t;
typedef cef_string_userfree_utf16_t cef_string_userfree_t;
typedef void* cef_string_list_t;
typedef void* cef_string_map_t;
typedef void* cef_string_multimap_t;



