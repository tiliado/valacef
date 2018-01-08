namespace Cefium {

public class Application : Gtk.Application {
    private BrowserWindow main_window;
    private string versions;
    
    public Application(string versions) {
		GLib.Object(application_id: "eu.tiliado.Cefium", flags: ApplicationFlags.FLAGS_NONE);
        this.versions = versions;
	}
    
    protected override void startup() {
		base.startup();
		var source = new IdleSource();
		source.set_callback(() => {
	        CefGtk.run_main_loop();
	        return false;
		});
		source.set_priority(GLib.Priority.HIGH);
		source.set_can_recurse(false);
		source.attach(MainContext.ref_thread_default());
	}
    
    protected override void activate () {
        create_main_window();
        main_window.present();
    }
    
    private void create_main_window() {
        if (main_window == null) {
            var ctx = new CefGtk.WebContext(GLib.Environment.get_user_config_dir() + "/cefium");
            var web_view = new CefGtk.WebView(ctx);
            web_view.add_autoloaded_renderer_extension(
                Environment.get_variable("CEFIUM_RENDERER_EXTENSION") ?? LIBDIR + "/libcefiumrendererextension.so",
                new Variant[]{"hello", 123});
            var win = new BrowserWindow(this, web_view, Args.url ?? "https://github.com/tiliado/valacef/wiki", versions);
            win.quit.connect(() => {CefGtk.quit_main_loop(); quit();});
            win.set_default_size(1100, 800);
            main_window = win;
            add_window(win);
        }
    }
}

} // namespace Cefium 
