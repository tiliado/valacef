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

public void override_system_visual(Gdk.Visual visual) {
    cef_override_system_visual(((Gdk.X11.Visual) visual).get_xvisual().visualid);
}

public void override_rgba_visual(Gdk.Visual visual) {
    cef_override_rgba_visual(((Gdk.X11.Visual) visual).get_xvisual().visualid);
}

public Gdk.Visual? get_visual_by_id(X.VisualID visual_id) {
    var screen = Gdk.Screen.get_default();
    var visuals = screen.list_visuals();
    var x11_screen = screen as Gdk.X11.Screen;
    assert(x11_screen != null);
    foreach (Gdk.Visual visual in visuals) {
        if (((Gdk.X11.Visual) visual).get_xvisual().visualid == visual_id) {
            return visual;
        }
    }
    return null;
}

public Gdk.X11.Window? find_child_window(Gdk.X11.Window window) {
    X.Window root = X.None;
    X.Window parent = X.None;
    X.Window[] children = null;
    var display = window.get_display() as Gdk.X11.Display;
    display.get_xdisplay().query_tree(window.get_xid(), out root, out parent, out children);
    return (children != null && children.length > 0) ? wrap_xwindow(display, children[0]) : null;
}

public Gdk.X11.Window wrap_xwindow(Gdk.X11.Display display, X.Window xwindow) {
    var window = Gdk.X11.Window.lookup_for_display(display, xwindow);
    return window != null ? window : new Gdk.X11.Window.foreign_for_display(display, xwindow);
}

} // namespace CefX11


private extern void cef_override_system_visual(X.VisualID id);
private extern void cef_override_rgba_visual(X.VisualID id);
