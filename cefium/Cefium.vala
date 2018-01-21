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
    Environment.set_variable("GDK_BACKEND", "x11", true);
    
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
    var window = new Gtk.Window();
    window.show();
    CefGtk.init(window.scale_factor * 1.0, !Args.disable_widevine, !Args.disable_flash);
    window.destroy();
    window = null;
	var app = new Application(versions);
    var result = app.run(gtk_argv);
	CefGtk.shutdown();
	return result;
}

} // namespace Cefium
