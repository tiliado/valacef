namespace Cefium {

public class BrowserWindow : Gtk.ApplicationWindow {
    public Gtk.Grid grid;
    private Gtk.HeaderBar header_bar;
    private Gtk.Label status_bar;
    private string? default_status;
    private CefGtk.WebView web_view;
    private URLBar url_bar;
    private string home_uri;
    
    public BrowserWindow(CefGtk.WebView web_view, string home_uri, string? default_status) {
        set_visual(CefGtk.get_default_visual());
        this.default_status = default_status;
        this.web_view = web_view;
        this.home_uri = home_uri;
        grid = new Gtk.Grid();
        grid.hexpand = grid.vexpand = true;
        add(grid);
        header_bar = new Gtk.HeaderBar();
        add_button("go-previous-symbolic", "go-back").activate.connect(() => web_view.go_back());
        add_button("go-next-symbolic", "go-forward").activate.connect(() => web_view.go_forward());
        add_button("go-home-symbolic", "go-home").activate.connect(() => go_home());
        add_button("view-refresh-symbolic", "reload").activate.connect(() => web_view.reload());
        add_button("process-stop-symbolic", "abort").activate.connect(() => web_view.stop_load());
        add_button("zoom-out-symbolic", "zoom-out", false).activate.connect(() => web_view.zoom_out());
        add_button("zoom-original-symbolic", "zoom-reset", false).activate.connect(() => web_view.zoom_reset());
        add_button("zoom-in-symbolic", "zoom-in", false).activate.connect(() => web_view.zoom_in());
        add_button("edit-select-all-symbolic", "edit-select-all", false).activate.connect(
            () => web_view.edit_select_all());
        add_button("edit-paste-symbolic", "edit-paste", false).activate.connect(() => web_view.edit_paste());
        add_button("edit-copy-symbolic", "edit-copy", false).activate.connect(() => web_view.edit_copy());
        add_button("edit-cut-symbolic", "edit-cut", false).activate.connect(() => web_view.edit_cut());
        add_button("edit-redo-symbolic", "edit-redo", false).activate.connect(() => web_view.edit_redo());
        add_button("edit-undo-symbolic", "edit-undo", false).activate.connect(() => web_view.edit_undo());
        url_bar = new URLBar(null);
        url_bar.hexpand = true;
        url_bar.margin = 5;
        url_bar.response.connect(on_url_bar_response);
        header_bar.custom_title = url_bar;
        status_bar = new Gtk.Label(default_status);
        status_bar.hexpand = true;
        status_bar.halign = Gtk.Align.START;
        status_bar.margin = 5;
        status_bar.ellipsize = Pango.EllipsizeMode.MIDDLE;
        web_view.hexpand = web_view.vexpand = true;
        grid.attach(header_bar, 0, 0, 1, 1);
        grid.attach(web_view, 0, 1, 1, 1);
        grid.attach(status_bar, 0, 5, 1, 1);
        grid.show_all();
        web_view.notify.connect_after(on_web_view_notify);
        update("title");
        update("uri");
        update("status-message");
        update("is-loading");
        update("can-go-back");
        update("can-go-forward");
        go_home();
    }
    
    public void go_home() {
        web_view.load_uri(home_uri);
    }
    
    private GLib.SimpleAction add_button(string icon, string action_name, bool start=true) {
        var action = new GLib.SimpleAction(action_name, null);
        action.set_enabled(true);
        add_action(action);
        var button = new Gtk.Button.from_icon_name(icon);
        button.action_name = "win." + action_name;
        if (start) {
            header_bar.pack_start(button);
        } else {
            header_bar.pack_end(button);
        }
        return action;
    }
    
    private void on_web_view_notify(GLib.Object? o, ParamSpec param) {
        update(param.name);
    }
    
    private void update(string property) {
        switch (property) {
        case "title":
            var title = web_view.title;
            title = title != null && title != "" ? title + " ~~ " : "";
            this.title = title + "Cefium browser " + Cef.get_valacef_version();
            break;
        case "uri":
            url_bar.url = web_view.uri ?? "";
            break;
        case "status-message":
            status_bar.label = web_view.status_message ?? default_status ?? "";
            break;
        case "is-loading":
            set_action_enabled("abort", web_view.is_loading);
            break;
        case "can-go-back":
            set_action_enabled("go-back", web_view.can_go_back);
            break;
        case "can-go-forward":
            set_action_enabled("go-forward", web_view.can_go_forward);
            break;
        }
    }
    
    public void set_action_enabled(string name, bool enabled) {
        var action = lookup_action(name) as GLib.SimpleAction;
        return_if_fail(action != null);
        action.set_enabled(enabled);
    }
    private void on_url_bar_response(bool accepted) {
        if (accepted) {
            web_view.load_uri(url_bar.url);
        }
    }
}

} // namespace Cefium
