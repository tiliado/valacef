namespace Cefium {

private extern const string LIBDIR;

struct Args {
    static bool disable_widevine = false;
    static string? flash_dir = null;
    static string? url = null;
    public const OptionEntry[] main_options = {
        {"url", 'U', 0, OptionArg.STRING, ref Args.url, "Load URL", "URL" },
        {"disable-widevine", 0, 0, OptionArg.NONE, ref Args.disable_widevine,
             "Disable widevine DRM plugin.", null},
        {"flash-dir", 0, 0, OptionArg.STRING, ref Args.flash_dir,
            "Adobe Flash plugin directory.", null},
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
    var flags = new CefGtk.InitFlags();
    flags.auto_play_policy = CefGtk.AutoPlayPolicy.NO_USER_GESTURE_REQUIRED;
    CefGtk.init(flags, window.scale_factor * 1.0, Args.disable_widevine? null : Cef.get_cef_lib_dir(), Args.flash_dir);
    window.destroy();
    window = null;
    var app = new Application(versions);
    var result = app.run(gtk_argv);
    CefGtk.shutdown();
    return result;
}

} // namespace Cefium
