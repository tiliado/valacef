namespace CefGtk {

public interface WebViewWidget : Gtk.Widget {
    public signal void browser_created(Client client, Cef.Browser browser);

    public virtual Gdk.Pixbuf? get_snapshot() {
        Gtk.Allocation allocation;
        get_allocation(out allocation);
        return Gdk.pixbuf_get_from_window(get_window(), 0, 0, allocation.width, allocation.height);
    }
}

} // namespace CefGtk
