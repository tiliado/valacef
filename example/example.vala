int main(string[] argv) {
	var versions = "ValaCEF %s, CEF %s, Chrome %s, GTK+ %u.%u.%u".printf(
		Cef.get_valacef_version(), Cef.get_cef_version(), Cef.get_chrome_version(),
		Gtk.get_major_version(), Gtk.get_minor_version(), Gtk.get_micro_version());
	message("Versions: %s", versions);
	
	CefGtk.init();
	unowned string[]? gtk_argv = null;
	Gtk.init(ref gtk_argv);
	var win = new Gtk.Window();
	win.set_visual(CefGtk.get_default_visual());
	win.title = versions;
	win.delete_event.connect(() => {Gtk.main_quit(); return true;});
	win.set_default_size(800, 600);
	var panels = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
	win.add(panels);
	panels.add1(new Gtk.Entry());
	panels.add2(new CefGtk.WebView());
	win.realize();
	win.show_all();
	Gtk.main();
	CefGtk.quit();
	return 0;
}
