namespace Example {

public class BrowserWindow : Gtk.Window {
    public Gtk.Grid grid;
    private Gtk.Label status_bar;
    private string? default_status;
    private CefGtk.WebView web_view;
    private Gtk.Entry address_entry;
    
    public BrowserWindow(CefGtk.WebView web_view, string? default_status) {
        set_visual(CefGtk.get_default_visual());
        this.default_status = default_status;
        this.web_view = web_view;
        grid = new Gtk.Grid();
        grid.hexpand = grid.vexpand = true;
        add(grid);
        address_entry = new Gtk.Entry();
        address_entry.hexpand = true;
        address_entry.margin = 5;
        status_bar = new Gtk.Label(default_status);
        status_bar.hexpand = true;
        status_bar.halign = Gtk.Align.START;
        status_bar.margin = 5;
        web_view.hexpand = web_view.vexpand = true;
        grid.attach(address_entry, 0, 0, 1, 1);
        grid.attach(web_view, 0, 1, 1, 1);
        grid.attach(status_bar, 0, 5, 1, 1);
        grid.show_all();
    }
}

} // namespace Example
