extern const string CEF_LIB_DIR;

namespace CefSubprocess {

int main(string[] argv) {
	Cef.String cef_path = {};
	Cef.set_string(&cef_path, CEF_LIB_DIR);
	Cef.override_path(Cef.PathKey.DIR_MODULE, &cef_path);
	Cef.override_path(Cef.PathKey.DIR_EXE, &cef_path);
	var app = new Cef.AppRef();
	Cef.MainArgs main_args = {argv.length, argv};
	var code = Cef.execute_process(main_args, app, null);
	if (code >= 0) {
		return code;
	} else {
        assert_not_reached();
    }
}

} // namespace CefSubprocess
