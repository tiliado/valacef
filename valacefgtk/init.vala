extern const string VALACEF_LIBDIR;

namespace CefGtk {

private static InitializationResult? initialization_result = null;
private static uint message_loop_source_id = 0;

public class InitializationResult {
	public string cef_lib_dir {get; private set;}
	public WidevinePlugin? widevine_plugin {get; private set;}
	public FlashPlugin? flash_plugin {get; private set;}
    public BrowserProcess app {get; private set;}

	public InitializationResult(BrowserProcess app, string cef_lib_dir, WidevinePlugin? widevine_plugin,
	FlashPlugin? flash_plugin) {
		this.cef_lib_dir = cef_lib_dir;
		this.widevine_plugin = widevine_plugin;
		this.flash_plugin = flash_plugin;
        this.app = app;
	}
}

public InitializationResult init(
    InitFlags? flags, double scale_factor,
    string? widevine_plugin_dir=null, bool enable_flash_plugin=true,
    string? user_agent=null, string? product_version=null,
    ProxyType proxy_type=ProxyType.SYSTEM, string? proxy_server=null, uint proxy_port=0) {
	assert (initialization_result == null);
    Cef.enable_highdpi_support();
	set_x11_error_handlers();
	Cef.String cef_path = {};
	Cef.set_string(&cef_path, Cef.get_cef_lib_dir());
	Cef.override_path(Cef.PathKey.DIR_MODULE, &cef_path);
	Cef.override_path(Cef.PathKey.DIR_EXE, &cef_path);

	Cef.MainArgs main_args = {0, null};
	FlashPlugin? flash_plugin = null;
	if (enable_flash_plugin) {
        flash_plugin = new FlashPlugin();
        if (!flash_plugin.register(Cef.get_cef_lib_dir() + "/PepperFlash")) {
            warning("Failed to register Flash plugin: %s", flash_plugin.registration_error);
        }
	}
	var app = new BrowserProcess(flags, flash_plugin, scale_factor, new ProxySettings(proxy_type, proxy_server, proxy_port));
	var code = Cef.execute_process(main_args, app, null);
	assert(code < 0);

	Cef.Settings settings = {sizeof(Cef.Settings)};
	settings.no_sandbox = 1;
	/* Even if we use a fixed 50 ms timer (see bellow),
	 * turning the external_message_pump on decreases CPU usage rapidly. */
    // But clipboard paste does not work: tiliado/valacef#2
	settings.external_message_pump = (int) ((Environment.get_variable("CEF_EXTERNAL_MESSAGE_PUMP") ?? "no") == "yes");
	settings.log_severity = Cef.LogSeverity.WARNING;
	Cef.set_string(&settings.resources_dir_path, Cef.get_cef_lib_dir());
	Cef.set_string(&settings.locales_dir_path, Cef.get_cef_lib_dir() + "/locales");
	var subprocess_path = Environment.get_variable("CEF_SUBPROCESS_PATH") ?? (VALACEF_LIBDIR + "/ValacefSubprocess");
	assert(FileUtils.test(subprocess_path, FileTest.IS_EXECUTABLE));
	Cef.set_string(&settings.browser_subprocess_path, subprocess_path);
	WidevinePlugin? widevine_plugin = null;
	if (widevine_plugin_dir != null) {
        File base_dir = File.new_for_path(widevine_plugin_dir);
        File libwidevine = base_dir.get_child("libwidevinecdm.so");
        File adapter = base_dir.get_child("libwidevinecdmadapter.so");
        File manifest = base_dir.get_child("manifest.json");
        if (libwidevine.query_exists()) {
            try {
                if (adapter.query_file_type(GLib.FileQueryInfoFlags.NONE, null) != GLib.FileType.REGULAR) {
                    try {
                        adapter.@delete(null);
                    } catch (GLib.Error e) {
                        debug("Failed to remove '%s'. %s", adapter.get_path(), e.message);
                    }
                    adapter.make_symbolic_link(Cef.get_widevine_adapter_path(), null);
                }
                if (manifest.query_file_type(GLib.FileQueryInfoFlags.NONE, null) != GLib.FileType.REGULAR) {
                    try {
                        manifest.@delete(null);
                    } catch (GLib.Error e) {
                        debug("Failed to remove '%s'. %s", manifest.get_path(), e.message);
                    }
                    manifest.make_symbolic_link(Cef.get_widevine_manifest_path(), null);
                }
            } catch (GLib.Error e) {
                warning("Failed to set up Widevine adapter/manifest symlinks. %s", e.message);
            }
            widevine_plugin = new WidevinePlugin();
            widevine_plugin.register(widevine_plugin_dir);
        } else {
            warning("%s does not exist.", libwidevine.get_path());
        }
	} else {
        debug("No widevine plugin dir.");
    }
    if (user_agent != null) {
        Cef.set_string(&settings.user_agent, user_agent);
    } else if (product_version != null) {
        Cef.set_string(&settings.product_version, product_version);
    }

	Cef.initialize(main_args, settings, app, null);
	var source = new TimeoutSource(20);
	source.set_priority(GLib.Priority.DEFAULT_IDLE);
	source.set_callback(() => {
		Cef.do_message_loop_work();
		return true;
	});
	source.set_can_recurse(false);
	message_loop_source_id = source.attach(MainContext.ref_thread_default());

	initialization_result = new InitializationResult(app, Cef.get_cef_lib_dir(), widevine_plugin, flash_plugin);
	return initialization_result;
}

public bool is_initialized() {
	return initialization_result != null;
}

public InitializationResult? get_init_result() {
	return initialization_result;
}

public void run_main_loop() {
    if (is_initialized()) {
        if (message_loop_source_id > 0) {
            Source.remove(message_loop_source_id);
            message_loop_source_id = 0;
        }
        Cef.run_message_loop();
    }
}

public void quit_main_loop() {
    if (is_initialized()) {
        Cef.quit_message_loop();
    }
}

public void shutdown() {
	if (is_initialized()) {
        if (message_loop_source_id > 0) {
            Source.remove(message_loop_source_id);
            message_loop_source_id = 0;
        }
        Cef.shutdown();
    }
}

} // namespace CefGtk
