namespace Cef {

[CCode (cname="CEF_LIB_DIR")]
private extern const string CEF_LIB_DIR;
[CCode (cname="VALACEF_WIDEVINE_MANIFEST_PATH")]
private extern const string WIDEVINE_MANIFEST_PATH;
private static unowned string? cached_cef_lib_dir;
private static unowned string? cached_widevine_manifest_path;
private static string? cached_widevine_adapter_path;
private static string? minimal_chromium_version_for_widevine = null;

public unowned string get_cef_lib_dir() {
    if (cached_cef_lib_dir == null) {
        cached_cef_lib_dir = Environment.get_variable("CEF_LIB_DIR") ?? CEF_LIB_DIR;
    }
    return cached_cef_lib_dir;
}


public unowned string get_widevine_manifest_path() {
    if (cached_widevine_manifest_path == null) {
        cached_widevine_manifest_path = Environment.get_variable(
            "VALACEF_WIDEVINE_MANIFEST_PATH") ?? WIDEVINE_MANIFEST_PATH;
    }
    return cached_widevine_manifest_path;
}


public unowned string get_widevine_adapter_path() {
    if (cached_widevine_adapter_path == null) {
        cached_widevine_adapter_path = get_cef_lib_dir() + "/libwidevinecdmadapter.so";
    }
    return cached_widevine_adapter_path;
}


public unowned string get_minimal_chromium_version_for_widevine() {
    if (minimal_chromium_version_for_widevine == null) {
        minimal_chromium_version_for_widevine = Cef.get_chromium_major().to_string();
    }
    return minimal_chromium_version_for_widevine;
}

} // namespace Cef
