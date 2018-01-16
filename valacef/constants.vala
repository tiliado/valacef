namespace Cef {

[CCode (cname="CEF_LIB_DIR")]
private extern const string CEF_LIB_DIR;

private static unowned string? cached_cef_lib_dir;

public unowned string get_cef_lib_dir() {
    if (cached_cef_lib_dir == null) {
        cached_cef_lib_dir = Environment.get_variable("CEF_LIB_DIR") ?? CEF_LIB_DIR;
    }
    return cached_cef_lib_dir;
}

} // namespace Cef
