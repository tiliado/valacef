extern const string CEF_LIB_DIR;
extern const string VALACEF_LIBDIR;

namespace CefGtk {

private static InitializationResult? initialization_result = null;
private static uint message_loop_source_id = 0;

public class InitializationResult {
	public string cef_lib_dir {get; private set;}
	public WidevinePlugin? widevine_plugin {get; private set;}
	public FlashPlugin? flash_plugin {get; private set;}
	
	public InitializationResult(string cef_lib_dir, WidevinePlugin? widevine_plugin,
	FlashPlugin? flash_plugin) {
		this.cef_lib_dir = cef_lib_dir;
		this.widevine_plugin = widevine_plugin;
		this.flash_plugin = flash_plugin;
	}
}

public InitializationResult init(bool enable_widevine_plugin=true, bool enable_flash_plugin=true,
string? user_agent=null, string? product_version=null) {
	assert (initialization_result == null);
	set_x11_error_handlers();
	Cef.String cef_path = {};
	Cef.set_string(&cef_path, CEF_LIB_DIR);
	Cef.override_path(Cef.PathKey.DIR_MODULE, &cef_path);
	Cef.override_path(Cef.PathKey.DIR_EXE, &cef_path);
	
	Cef.MainArgs main_args = {0, null};
	FlashPlugin? flash_plugin = null; 
	if (enable_flash_plugin) {
        flash_plugin = new FlashPlugin();
        if (!flash_plugin.register(CEF_LIB_DIR + "/PepperFlash")) {
            warning("Failed to register Flash plugin: %s", flash_plugin.registration_error);
        }
	}
	var app = new BrowserProcess(flash_plugin);
	var code = Cef.execute_process(main_args, app, null);
	assert(code < 0);
	
	Cef.Settings settings = {sizeof(Cef.Settings)};
	settings.no_sandbox = 1;
	/* Even if we use a fixed 50 ms timer (see bellow),
	 * turning the external_message_pump on decreases CPU usage rapidly. */
	settings.external_message_pump = 1;
	settings.log_severity = Cef.LogSeverity.WARNING;
	Cef.set_string(&settings.resources_dir_path, CEF_LIB_DIR);
	Cef.set_string(&settings.locales_dir_path, CEF_LIB_DIR + "/locales");
	var subprocess_path = Environment.get_variable("CEF_SUBPROCESS_PATH") ?? (VALACEF_LIBDIR + "/ValacefSubprocess");
	assert(FileUtils.test(subprocess_path, FileTest.IS_EXECUTABLE));
	Cef.set_string(&settings.browser_subprocess_path, subprocess_path);
	WidevinePlugin? widevine_plugin = null;
	if (enable_widevine_plugin) {
        widevine_plugin = new WidevinePlugin();
		widevine_plugin.register(CEF_LIB_DIR);
	}
    if (user_agent != null) {
        Cef.set_string(&settings.user_agent, user_agent);
    } else if (product_version != null) {
        Cef.set_string(&settings.product_version, product_version);
    }
	
	Cef.initialize(main_args, settings, app, null);
	message_loop_source_id = GLib.Timeout.add(20, () => {
		Cef.do_message_loop_work();
		return true;
	});
	initialization_result = new InitializationResult(CEF_LIB_DIR, widevine_plugin, flash_plugin);
	return initialization_result;
}

public bool is_initialized() {
	return initialization_result != null;
}

public InitializationResult? get_init_result() {
	return initialization_result;
}

public void quit() {
	if (is_initialized()) {
        Source.remove(message_loop_source_id);
        Cef.shutdown();
    }
}

} // namespace CefGtk
