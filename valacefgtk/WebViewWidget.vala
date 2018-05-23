namespace CefGtk {

public interface WebViewWidget : Gtk.Widget {
    
    public signal void browser_created(Client client, Cef.Browser browser);
    public abstract Gdk.Pixbuf? get_snapshot();
}

} // namespace CefGtk
