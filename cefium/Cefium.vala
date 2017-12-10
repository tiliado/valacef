namespace Cefium {
	
int main(string[] argv) {
	var versions = "ValaCEF %s, CEF %s, Chrome %s, GTK+ %u.%u.%u".printf(
		Cef.get_valacef_version(), Cef.get_cef_version(), Cef.get_chrome_version(),
		Gtk.get_major_version(), Gtk.get_minor_version(), Gtk.get_micro_version());
	message("Versions: %s", versions);
	unowned string[]? gtk_argv = null;
	Gtk.init(ref gtk_argv);
	var win = new BrowserWindow(new CefGtk.WebView(), versions);
	win.delete_event.connect(() => {Gtk.main_quit(); return true;});
	win.set_default_size(800, 600);
	win.present();
	Gtk.main();
	CefGtk.quit();
	return 0;
}

} // namespace Cefium
