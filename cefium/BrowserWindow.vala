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
        status_bar.ellipsize = Pango.EllipsizeMode.MIDDLE;
        web_view.hexpand = web_view.vexpand = true;
        grid.attach(address_entry, 0, 0, 1, 1);
        grid.attach(web_view, 0, 1, 1, 1);
        grid.attach(status_bar, 0, 5, 1, 1);
        grid.show_all();
        web_view.notify.connect_after(on_web_view_notify);
        update("title");
        update("uri");
        update("status-message");
    }
    
    private void on_web_view_notify(GLib.Object? o, ParamSpec param) {
        update(param.name);
    }
    
    private void update(string property) {
        switch (property) {
        case "title":
            title = web_view.title ?? default_status;
            break;
        case "uri":
            address_entry.set_text(web_view.uri ?? "");
            break;
        case "status-message":
            status_bar.label = web_view.status_message ?? default_status ?? "";
            break;
        }
    }
}

} // namespace Example
