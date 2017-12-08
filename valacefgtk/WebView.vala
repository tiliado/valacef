namespace CefGtk {

public class WebView : Gtk.Widget {
    private Cef.Browser? browser = null;
    
    public WebView() {
    }
    
    public override void get_preferred_width(out int minimum_width, out int natural_width) {
        minimum_width = natural_width = 100;
    }
    
    public override void get_preferred_height(out int minimum_height, out int natural_height) {
        minimum_height = natural_height = 100;
    }
    
    public override void realize() {
        set_window(embed_cef());
        set_realized(true);
    }
    
    private Gdk.X11.Window? embed_cef() {
		assert(CefGtk.is_initialized());
		var toplevel = get_toplevel();
		assert(toplevel.is_toplevel());
		if (toplevel.get_visual() != CefGtk.get_default_visual()) {
			error("Incompatible window visual. Use `window.set_visual(CefGtk.get_default_visual())`.");
		}
        Gtk.Allocation clip;
        get_clip(out clip);
        var parent_window = get_parent_window() as Gdk.X11.Window;
        assert(parent_window != null);
        Cef.WindowInfo window_info = {};
        window_info.parent_window = (Cef.WindowHandle) parent_window.get_xid();
        window_info.x = clip.x;
        window_info.y = clip.y;
        window_info.width = clip.width;
        window_info.height = clip.height;
        Cef.BrowserSettings browser_settings = {sizeof(Cef.BrowserSettings)};
        var client = new Cef.ClientRef();
        Cef.String url = {};
        Cef.set_string(ref url, "https://www.google.com");
        browser = Cef.browser_host_create_browser_sync(window_info, client, ref url, browser_settings, null);
        var host = browser.get_host(browser);
		return new Gdk.X11.Window.foreign_for_display(
			parent_window.get_display() as Gdk.X11.Display, (X.Window) host.get_window_handle(host));
    }
}

} // namespace CefGtk
