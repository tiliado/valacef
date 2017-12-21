namespace Cefium {

private extern const string LIBDIR;

struct Args {
	static bool disable_widevine = false;
	static bool disable_flash = false;
    static string? url = null;	
	public const OptionEntry[] main_options = {
        {"url", 'U', 0, OptionArg.STRING, ref Args.url, "Load URL", "URL" },
		{"disable-widevine", 0, 0, OptionArg.NONE, ref Args.disable_widevine,
             "Disable widevine DRM plugin.", null},
		{"disable-flash", 0, 0, OptionArg.NONE, ref Args.disable_flash,
            "Disable Adobe Flash plugin.", null},
		{null}
	};
}

int main(string[] argv) {
    try {
		var opt_context = new OptionContext("- Cefium %s".printf(Cef.get_valacef_version()));
		opt_context.set_help_enabled(true);
		opt_context.add_main_entries(Args.main_options, null);
		opt_context.set_ignore_unknown_options(false);
		opt_context.parse(ref argv);
	} catch (OptionError e) {
		stderr.printf("Error: Option parsing failed: %s\n", e.message);
		return 1;
	}
	var versions = "Cefium browser powered by ValaCEF %s, CEF %s, Chromium %s, GTK+ %u.%u.%u".printf(
		Cef.get_valacef_version(), Cef.get_cef_version(), Cef.get_chromium_version(),
		Gtk.get_major_version(), Gtk.get_minor_version(), Gtk.get_micro_version());
	message("Versions: %s", versions);
	unowned string[]? gtk_argv = null;
	Gtk.init(ref gtk_argv);
    CefGtk.init(!Args.disable_widevine, !Args.disable_flash);
    var ctx = new CefGtk.WebContext(GLib.Environment.get_user_config_dir() + "/cefium");
    var web_view = new CefGtk.WebView(ctx);
    web_view.ready.connect((w) => w.load_renderer_extension(
        Environment.get_variable("CEFIUM_RENDERER_EXTENSION") ?? LIBDIR + "/libcefiumrendererextension.so",
        new Variant[]{"hello", 123}));
	var win = new BrowserWindow(web_view, Args.url ?? "https://github.com/tiliado/valacef/wiki", versions);
	win.delete_event.connect(() => {Gtk.main_quit(); return true;});
	win.set_default_size(1100, 800);
	win.present();
	Gtk.main();
	CefGtk.quit();
	return 0;
}

} // namespace Cefium
