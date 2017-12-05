public class MyApp: Cef.AppRef {
	public MyApp() {
		base();
	}
}

int main(string[] argv) {
	Cef.String cef_path = {};
	Cef.set_string(ref cef_path, "/app/lib/cef");
	Cef.override_path(Cef.PathKey.DIR_MODULE, ref cef_path);
	Cef.override_path(Cef.PathKey.DIR_EXE, ref cef_path);
	
	var app = new MyApp();
	app.ref();
	Cef.MainArgs main_args = {argv.length, argv};
	var code = Cef.execute_process(main_args, app, null);
	if (code >= 0) {
		return code;
	}
	
	Cef.Settings settings = {sizeof(Cef.Settings)};
	settings.no_sandbox = 1;
	settings.log_severity = Cef.LogSeverity.WARNING;
	Cef.set_string(ref settings.resources_dir_path, "/app/lib/cef");
	Cef.set_string(ref settings.locales_dir_path, "/app/lib/cef/locales");
	Cef.initialize(main_args, settings, app, null);
	
	unowned string[]? gtk_argv = null;
	Gtk.init(ref gtk_argv);
	CefX11.set_x11_error_handlers();
	var win = new Gtk.Window();
	CefX11.fix_default_visual(win);
	win.title = "ValaCEF";
	win.delete_event.connect(() => {Gtk.main_quit(); return true;});
	win.set_default_size(800, 600);
	win.realize();
	
	var xid = (win.get_window() as Gdk.X11.Window).get_xid();
	Cef.WindowInfo window_info = {};
	window_info.parent_window = (Cef.WindowHandle) xid;
	window_info.width = 800;
	window_info.height = 600;
	Cef.BrowserSettings browser_settings = {sizeof(Cef.BrowserSettings)};
	var client = new Cef.ClientRef();
	Cef.String url = {};
	Cef.set_string(ref url, "https://www.google.com");
	win.show_all();
	var browser = Cef.browser_host_create_browser_sync(window_info, client, ref url, browser_settings, null);
	var message_loop_source_id = GLib.Timeout.add(30, () => {
		Cef.do_message_loop_work();
		return true;
	});
	var host = browser.get_host(browser);
	host.get_window_handle(host);
	win.show_all();
	Gtk.main();
	Source.remove(message_loop_source_id);
	Cef.shutdown();
	return 0;
}
