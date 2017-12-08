namespace CefGtk {

public void set_x11_error_handlers() {
	X.set_io_error_handler((d) => 0);
	X.set_error_handler((display, event) => {
		critical(
			"X11 error: type=%d, serial=%lu, code=%d",
			event.type, event.serial, (int) event.error_code);
		return 0;
	});
    
}

public Gdk.Visual get_default_visual() {
    // GTK+ > 3.15.1 uses an X11 visual optimized for GTK+'s OpenGL stuff
    // since revid dae447728d: https://github.com/GNOME/gtk/commit/dae447728d
    // However, it breaks CEF: https://github.com/cztomczak/cefcapi/issues/9
    // Let's use the default X11 visual instead of the GTK's blessed one.
    var screen = Gdk.Screen.get_default();
    var visuals = screen.list_visuals();
    var x11_screen = screen as Gdk.X11.Screen;
    assert(x11_screen != null);
    var default_xvisual = x11_screen.get_xscreen().default_visual_of_screen();
    foreach (Gdk.Visual visual in visuals) {
        if (default_xvisual.visualid == ((Gdk.X11.Visual) visual).get_xvisual().visualid) {
            return visual;
        }
    }
    assert_not_reached();
}

} // namespace CefX11
