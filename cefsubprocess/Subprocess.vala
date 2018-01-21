namespace CefGtk {

int main(string[] argv) {
	Cef.String cef_path = {};
	Cef.set_string(&cef_path, Cef.get_cef_lib_dir());
	Cef.override_path(Cef.PathKey.DIR_MODULE, &cef_path);
	Cef.override_path(Cef.PathKey.DIR_EXE, &cef_path);
    Cef.enable_highdpi_support();
	var app = new CefGtk.RenderProcess();
	Cef.MainArgs main_args = {argv.length, argv};
	var code = Cef.execute_process(main_args, app, null);
	if (code >= 0) {
		return code;
	} else {
        assert_not_reached();
    }
}

} // namespace CefSubprocess
