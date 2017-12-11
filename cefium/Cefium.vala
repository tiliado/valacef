namespace Cefium {
	
int main(string[] argv) {
	var versions = "Cefium browser powered by ValaCEF %s, CEF %s, Chrome %s, GTK+ %u.%u.%u".printf(
		Cef.get_valacef_version(), Cef.get_cef_version(), Cef.get_chrome_version(),
		Gtk.get_major_version(), Gtk.get_minor_version(), Gtk.get_micro_version());
	message("Versions: %s", versions);
	unowned string[]? gtk_argv = null;
	Gtk.init(ref gtk_argv);
    CefGtk.init(true, true);
    var ctx = new CefGtk.WebContext("cefium_data");
	var win = new BrowserWindow(new CefGtk.WebView(ctx), versions);
	win.delete_event.connect(() => {Gtk.main_quit(); return true;});
	win.set_default_size(1024, 800);
	win.present();
	Gtk.main();
	CefGtk.quit();
	return 0;
}

} // namespace Cefium
