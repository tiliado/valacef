extern const string CEF_LIB_DIR;

namespace CefGtk {

private static bool initialized = false;
private static uint message_loop_source_id = 0;

public void init() {
	if (!initialized) {
		set_x11_error_handlers();
		Cef.String cef_path = {};
		Cef.set_string(ref cef_path, CEF_LIB_DIR);
		Cef.override_path(Cef.PathKey.DIR_MODULE, ref cef_path);
		Cef.override_path(Cef.PathKey.DIR_EXE, ref cef_path);
		
		Cef.MainArgs main_args = {0, null};
		var app = new Cef.AppRef();
		var code = Cef.execute_process(main_args, app, null);
		assert(code < 0);
		
		Cef.Settings settings = {sizeof(Cef.Settings)};
		settings.no_sandbox = 1;
		settings.log_severity = Cef.LogSeverity.WARNING;
		Cef.set_string(ref settings.resources_dir_path, CEF_LIB_DIR);
		Cef.set_string(ref settings.locales_dir_path, CEF_LIB_DIR + "/locales");
		var subprocess_path = Environment.get_variable("CEF_SUBPROCESS_PATH") ?? (CEF_LIB_DIR + "/CefSubprocess");
		assert(FileUtils.test(subprocess_path, FileTest.IS_EXECUTABLE));
		Cef.set_string(ref settings.browser_subprocess_path, subprocess_path);
		Cef.initialize(main_args, settings, app, null);
		message_loop_source_id = GLib.Timeout.add(30, () => {
			Cef.do_message_loop_work();
			return true;
		});
		initialized = true;
	}
}

public bool is_initialized() {
	return initialized;
}

public void quit() {
	if (initialized) {
		Source.remove(message_loop_source_id);
		initialized = false;
		Cef.shutdown();
	}
}

} // namespace CefGtk
