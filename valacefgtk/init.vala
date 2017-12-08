extern const string CEF_LIB_DIR;

namespace CefGtk {

private static bool initialized = false;
private static uint message_loop_source_id = 0;

public void init() {
	if (!initialized) {
		set_x11_error_handlers();
		var app = new Cef.AppRef();
		Cef.MainArgs main_args = {0, null};
		Cef.Settings settings = {sizeof(Cef.Settings)};
		settings.no_sandbox = 1;
		settings.log_severity = Cef.LogSeverity.WARNING;
		Cef.set_string(ref settings.resources_dir_path, CEF_LIB_DIR);
		Cef.set_string(ref settings.locales_dir_path, CEF_LIB_DIR + "/locales");
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
