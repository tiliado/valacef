namespace Cefium {

public class BrowserWindow : Gtk.ApplicationWindow {
    public Gtk.Grid grid;
    private Gtk.HeaderBar header_bar;
    private Gtk.HeaderBar tool_bar;
    private Gtk.Label status_bar;
    private string? default_status;
    private CefGtk.WebView web_view;
    private URLBar url_bar;
    private string home_uri;
    private unowned Gtk.Application app;
    private Gtk.Overlay overlay;
    Gtk.EventBox box;
    
    public BrowserWindow(Gtk.Application app, CefGtk.WebView web_view, string home_uri, string? default_status) {
        this.app = app;
        this.default_status = default_status;
        this.web_view = web_view;
        this.home_uri = home_uri;
        overlay = new Gtk.Overlay();
        header_bar = new Gtk.HeaderBar();
        header_bar.show_close_button = true;
        header_bar.show();
        set_titlebar(header_bar);
        grid = new Gtk.Grid();
        grid.hexpand = grid.vexpand = true;
        add(grid);
        tool_bar = new Gtk.HeaderBar();
        
        add_simple_action("go-back", "<Alt>Left").activate.connect(() => web_view.go_back());
        add_simple_action("go-forward", "<Alt>Right").activate.connect(() => web_view.go_forward());
        add_simple_action("go-home", "<Alt>Home").activate.connect(() => go_home());
        add_simple_action("reload", "<Control>r").activate.connect(() => web_view.reload());
        add_simple_action("abort", "Escape").activate.connect(() => web_view.stop_load());
        add_simple_action("zoom-out", "<Control>minus").activate.connect(() => web_view.zoom_out());
        add_simple_action("zoom-reset", "<Control>0").activate.connect(() => web_view.zoom_reset());
        add_simple_action("zoom-in", "<Control>plus").activate.connect(() => web_view.zoom_in());
        add_simple_action("edit-select-all", "<Control>A").activate.connect(() => web_view.edit_select_all());
        add_simple_action("edit-paste").activate.connect(() => web_view.edit_paste());
        add_simple_action("edit-copy").activate.connect(() => web_view.edit_copy());
        add_simple_action("edit-cut").activate.connect(() => web_view.edit_cut());
        add_simple_action("edit-redo").activate.connect(() => web_view.edit_redo());
        add_simple_action("edit-undo").activate.connect(() => web_view.edit_undo());
        add_simple_action("open-developer-tools", "<Control><Shift>c").activate.connect(() => web_view.open_developer_tools());
        add_simple_action("quit", "<Control>q").activate.connect(() => quit());
        
        add_buttons({
            "(", "go-previous-symbolic|go-back", "go-next-symbolic|go-forward", ")",
            "(", "go-home-symbolic|go-home", "view-refresh-symbolic|reload", "process-stop-symbolic|abort", ")",
            "|",
            "preferences-other-symbolic|open-developer-tools",
            "(", "zoom-in-symbolic|zoom-in", "zoom-original-symbolic|zoom-reset", "zoom-out-symbolic|zoom-out", ")",
            "(", "edit-undo-symbolic|edit-undo", "edit-redo-symbolic|edit-redo", ")",
            "(", "edit-cut-symbolic|edit-cut", "edit-copy-symbolic|edit-copy",
            "edit-paste-symbolic|edit-paste", "edit-select-all-symbolic|edit-select-all", ")",
        });
        
        url_bar = new URLBar(null);
        url_bar.hexpand = true;
        url_bar.response.connect(on_url_bar_response);
        tool_bar.custom_title = url_bar;
        status_bar = new Gtk.Label(default_status);
        status_bar.hexpand = true;
        status_bar.halign = Gtk.Align.START;
        status_bar.margin = 5;
        status_bar.ellipsize = Pango.EllipsizeMode.MIDDLE;
        web_view.hexpand = web_view.vexpand = true;
        overlay.add(web_view);
        
        box = new Gtk.EventBox();
        box.set_app_paintable(true);
        box.set_visual(box.get_screen().get_rgba_visual());
        box.override_background_color(Gtk.StateFlags.NORMAL, {1.0, 1.0, 1.0, 0.1});
        var button = new Gtk.Button.with_label("Close overlay");
        button.vexpand = button.hexpand = false;
        button.valign = button.halign = Gtk.Align.CENTER;
        button.clicked.connect((b) => {button.get_parent().get_parent().remove(button.get_parent());});
        button.show();
        box.add(button);
        box.show();
        overlay.add_overlay(box);
        overlay.hexpand = overlay.vexpand = true;
        grid.attach(tool_bar, 0, 0, 1, 1);
        grid.attach(overlay, 0, 1, 1, 1);
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
        delete_event.connect(() => {hide(); quit(); return true;});
    }
    
    public signal void quit();
    
    public void go_home() {
        web_view.load_uri(home_uri);
    }
    
    private GLib.SimpleAction add_simple_action(string action_name, string? accelerator=null) {
        var action = new GLib.SimpleAction(action_name, null);
        action.set_enabled(true);
        add_action(action);
        if (accelerator != null) {
            app.add_accelerator(accelerator, "win." + action_name, null);
        }
        return action;
    }
    
    private void add_buttons(string[] buttons) {
        Gtk.Grid? grid = null;
        bool start = true;
        foreach (var entry in buttons) {
            if (entry == "(") {
                grid = new Gtk.Grid();
                grid.orientation = Gtk.Orientation.HORIZONTAL;
                grid.get_style_context().add_class("linked");
                grid.hexpand = grid.vexpand = false;
                grid.halign = grid.valign = Gtk.Align.CENTER;
                if (start) {
                    tool_bar.pack_start(grid);
                } else {
                    tool_bar.pack_end(grid);
                }
            } else if (entry == ")") {
                grid = null;
            } else if (entry == "|") {
                start = false;
            } else {
                var data = entry.split("|");
                var button = new Gtk.Button.from_icon_name(data[0]);
                button.vexpand = false;
                button.valign = Gtk.Align.CENTER;
                button.action_name = "win." + data[1];
                if (grid != null) {
                    grid.add(button);
                } else if (start) {
                    tool_bar.pack_start(button);
                } else {
                    tool_bar.pack_end(button);
                }
            }
        }
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
            web_view.send_message("uri", {new Variant.string(url_bar.url)});
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
        case "fullscreen":
            if (web_view.fullscreen) {
                this.tool_bar.hide();
                this.status_bar.hide();
                fullscreen();
            } else {
                unfullscreen();
                this.tool_bar.show();
                this.status_bar.show();
            }
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
