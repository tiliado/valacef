namespace CefGtk {

public enum RenderingMode {
    WINDOWED;
}

public class WebView : Gtk.Bin {
    public string? title {get; internal set; default = null;}
    public string? uri {get; internal set; default = null;}
    public string? status_message {get; internal set; default = null;}
    public bool can_go_back {get; internal set; default = false;}
    public bool can_go_forward {get; internal set; default = false;}
    public bool is_loading {get; internal set; default = false;}
    public WebContext web_context {get; private set;}
    public DownloadManager download_manager {get; private set;}
    public bool fullscreen {get; private set; default = false;}
    public double scaling_factor {get; private set; default = 1.0;}
    public double zoom_level {
        get {
            if (browser == null) {
                return _zoom_level;
            }
            Cef.assert_browser_ui_thread();
            return translate_cef_zoom_to_percentage(browser.get_host().get_zoom_level());
        }
        set {
            _zoom_level = double.max(0.1, value);
            if (browser != null) {
                Cef.assert_browser_ui_thread();
                browser.get_host().set_zoom_level(translate_percentage_zoom_to_cef(_zoom_level));
            }
        }
    }
    public RenderingMode rendering_mode {get; construct; default = RenderingMode.WINDOWED;}
    public bool context_menu_visible {get; internal set; default = false;}

    private double translate_cef_zoom_to_percentage(double cef_zoom) {
        return Math.pow(1.2, cef_zoom) / scaling_factor;
    }

    private double translate_percentage_zoom_to_cef(double percentage_zoom) {
        return Math.log(percentage_zoom * scaling_factor) / Math.log(1.2);
    }

    private void update_dpi() {
        int dpi = Gtk.Settings.get_default().gtk_xft_dpi;
        double current_zoom_level = this.zoom_level;
        scaling_factor = dpi > 0 ? (1.0 * dpi / 1024 / 96) : 1.0;
        this.zoom_level = current_zoom_level;
    }

    private WebViewWidget web_view;
    private double _zoom_level = 0.0;
    private Cef.Browser? browser = null;
    private Client? client = null;
    private string? uri_to_load = null;
    private string? string_to_load = null;
    private Gtk.MessageDialog? js_dialog = null;
    private Cef.JsdialogCallback? js_dialog_callback = null;
    private Cef.JsdialogType js_dialog_type = Cef.JsdialogType.ALERT;
    private SList<RendererExtensionInfo> autoloaded_renderer_extensions = null;

    public WebView(WebContext web_context, RenderingMode rendering_mode = RenderingMode.WINDOWED) {
        GLib.Object(rendering_mode: rendering_mode);
        update_dpi();
        Gtk.Settings.get_default().notify["gtk-xft-dpi"].connect_after(update_dpi);
        set_has_window(false);
        this.web_context = web_context;
        web_context.render_process_created.connect(on_render_process_created);
        this.download_manager = new DownloadManager(this);
        this.web_view = new WebViewWindowed(this);
        set_can_focus(!web_view.get_can_focus());
        web_view.browser_created.connect(on_browser_created);
        add(web_view);
        web_view.show();
    }

    public virtual signal void ready() {
        if (zoom_level != _zoom_level) {
            zoom_level = _zoom_level;
        }
    }

    public signal void load_started(Cef.TransitionType transition);

    public signal void load_ended(int http_status_code);

    public signal void load_error(Cef.Errorcode error_code, string? error_text, string? failed_url);

    public virtual signal void console_message(string? source, int line, string? text) {
        message("Console: %s:%d: %s", source, line, text);
    }

    public virtual signal void message_received(string name, Variant?[]? parameters) {
        message("Message received from renderer: '%s'", name);
    }

    public virtual signal void renderer_created(uint id) {
        message("Renderer #%u created.", id);
    }

    public virtual signal void renderer_destroyed(uint id) {
        message("Renderer #%u destroyed.", id);
    }

    public virtual signal void discard_js_dialogs() {
        if (js_dialog != null) {
            js_dialog.response.disconnect(on_js_dialog_response);
            js_dialog.destroy();
            js_dialog = null;
            js_dialog_callback = null;
        }
    }

    public virtual signal void alert_dialog(ref bool handled, string? url, string? message_text,
    Cef.JsdialogCallback callback) {
        if (!handled && js_dialog == null) {
            Cef.assert_browser_ui_thread();
            js_dialog_callback = callback;
            js_dialog = new Gtk.MessageDialog(
                get_toplevel() as Gtk.Window,
                Gtk.DialogFlags.MODAL, Gtk.MessageType.WARNING, Gtk.ButtonsType.CLOSE,
                "The web page '%s' says:\n\n%s", url, message_text);
            handled = true;
            js_dialog_type = Cef.JsdialogType.ALERT;
            js_dialog.response.connect(on_js_dialog_response);
            js_dialog.show();
        }
    }

    public signal void confirm_dialog(ref bool handled, string? url, string? message_text,
    Cef.JsdialogCallback callback);

    public signal void prompt_dialog(ref bool handled, string? url, string? message_text, string? default_prompt_text,
    Cef.JsdialogCallback callback);

    public signal void navigation_request(NavigationRequest request);

    public bool is_ready() {
        return browser != null;
    }

    public void load_uri(string uri) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            Cef.String cef_uri = {};
            Cef.set_string(&cef_uri, uri);
            browser.get_main_frame().load_url(&cef_uri);
            uri_to_load = null;
            string_to_load = null;
        } else {
            uri_to_load = uri;
            string_to_load = null;
        }
    }

    public void load_html(owned string code, string fake_url) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            Cef.String _fake_url = {};
            Cef.set_string(&_fake_url, fake_url);
            Cef.String _code = {};
            Cef.set_string(&_code, code);
            browser.get_main_frame().load_string(&_code, &_fake_url);
            uri_to_load = null;
            string_to_load = null;
        } else {
            uri_to_load = fake_url;
            string_to_load = (owned) code;
        }
    }

    public bool start_download(string uri) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            Cef.String _uri = {};
            Cef.set_string(&_uri, uri);
            browser.get_host().start_download(&_uri);
            return true;
        }
        return false;
    }

    public async bool download_file(string uri, string destination, Cancellable? cancellable=null) {
        return yield download_manager.download_file(uri, destination, cancellable);
    }

    public void go_back() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.go_back();
        }
    }

    public void go_forward() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.go_forward();
        }
    }

    public void reload() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.reload();
        }
    }

    public void reload_ignore_cache() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.reload_ignore_cache();
        }
    }

    public void stop_load() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.stop_load();
        }
    }

    [Signal (action=true)]
    public void zoom_in() {
        zoom_level += 0.1;
    }

    [Signal (action=true)]
    public void zoom_out() {
        zoom_level -= 0.1;
    }

    [Signal (action=true)]
    public void zoom_reset() {
        zoom_level = 1.0;
    }

    [Signal (action=true)]
    public void edit_cut() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.cut();
            }
        }
    }

    [Signal (action=true)]
    public void edit_copy() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.copy();
            }
        }
    }

    [Signal (action=true)]
    public void edit_paste() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.paste();
            }
        }
    }

    [Signal (action=true)]
    public void edit_select_all() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.select_all();
            }
        }
    }

    [Signal (action=true)]
    public void edit_undo() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.undo();
            }
        }
    }

    [Signal (action=true)]
    public void edit_redo() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.redo();
            }
        }
    }

    public void open_developer_tools() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var host = browser.get_host();
            if (host.has_dev_tools() != 1) {
                Cef.WindowInfo window_info = {};
                window_info.parent_window = 0;
                window_info.x = 100;
                window_info.y = 100;
                window_info.width = 500;
                window_info.height = 500;
                Cef.BrowserSettings browser_settings = {sizeof(Cef.BrowserSettings)};
                browser_settings.javascript_access_clipboard = Cef.State.ENABLED;
                browser_settings.javascript_dom_paste = Cef.State.ENABLED;
                host.show_dev_tools(window_info, new Cef.ClientRef(), browser_settings, null);
            } else {
                host.show_dev_tools(null, null, null, null);
            }
        }
    }

    public void close_developer_tools() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var host = browser.get_host();
            if (host.has_dev_tools() == 1) {
                host.close_dev_tools();
            }
        }
    }

    public bool has_developer_tools() {
        if (browser == null) {
            return false;
        }
        Cef.assert_browser_ui_thread();
        return (bool) browser.get_host().has_dev_tools();
    }

    private void on_browser_created(Client client, Cef.Browser browser) {
        this.client = client;
        this.browser = browser;
        if (string_to_load != null) {
            load_html(string_to_load, uri_to_load);
        } else if (uri_to_load != null) {
            load_uri(uri_to_load);
        }
        ready();
    }

    public override void grab_focus() {
        base.grab_focus();
        if (get_can_focus()) {
            send_focus_toggled(true);
        }
    }

    public override bool focus_in_event(Gdk.EventFocus event) {
        send_focus_event(event);
        return base.focus_in_event(event);
    }

    public override bool focus_out_event(Gdk.EventFocus event) {
        send_focus_event(event);
        return base.focus_out_event(event);
    }

    public void send_focus_toggled(bool focused) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.get_host().send_focus_event((int) focused);
        }
    }

    public void send_focus_event(Gdk.EventFocus event) {
        send_focus_toggled((bool) event.@in);
    }

    public void send_click_event(Gdk.EventButton event) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            UIEvents.send_click_event(event, browser.get_host());
        }
    }

    public void send_scroll_event(Gdk.EventScroll event) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            UIEvents.send_scroll_event(event, browser.get_host());
        }
    }

    public void send_key_event(Gdk.EventKey event) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            UIEvents.send_key_event(event, browser.get_host());
        }
    }

    public void send_motion_event(Gdk.EventMotion event) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            UIEvents.send_motion_event(event, browser.get_host());
        }
    }

    public void send_message(string name, Variant?[] parameters) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            var msg = Utils.create_process_message(name, parameters);
            browser.send_process_message(Cef.ProcessId.RENDERER, msg);
        }
    }

    public void load_renderer_extension(string path, Variant?[]? parameters=null) {
         Variant?[] args;
         if (parameters != null && parameters.length > 0) {
             args = new Variant?[parameters.length + 1];
             for (var i = 0; i < parameters.length; i++) {
                 args[i + 1] = parameters[i];
             }
         } else {
             args = new Variant?[1];
         }
         args[0] = new Variant.string(path);
         send_message(MsgId.LOAD_RENDERER_EXTENSION, args);
     }

     public RendererExtensionInfo add_autoloaded_renderer_extension(string path, Variant?[]? parameters=null) {
         var extension = new RendererExtensionInfo(browser == null ? -1 : browser.get_identifier(), path, parameters);
         autoloaded_renderer_extensions.append(extension);
         return extension;
     }

    private void on_render_process_created(Cef.ListValue extra_info) {
        foreach (var extension in autoloaded_renderer_extensions) {
            var n_params = extension.parameters == null ? 0 : extension.parameters.length;
            var list = Cef.list_value_create();
            list.set_size(3);
            Cef.String cef_string = {};
            Cef.set_string(&cef_string, MsgId.AUTOLOAD_EXTENSION);
            list.set_string(0, &cef_string);
            list.set_int(1, extension.browser_id != -1 ? extension.browser_id: browser.get_identifier());

            var params = Cef.list_value_create();
            if (n_params > 0) {
                Utils.set_list_from_variant(params, extension.parameters, 1);
            } else {
                params.set_size(1);
            }
            Cef.set_string(&cef_string, extension.path);
            params.set_string(0, &cef_string);
            params.ref();
            list.set_list(2, params);

            var index = extra_info.get_size();
            extra_info.set_size(index + 1);
            list.ref();
            extra_info.set_list(index, list);
        }
    }

    internal bool on_message_received(Cef.Browser? browser, Cef.ProcessMessage? msg) {
        if (browser.get_identifier() != this.browser.get_identifier()) {
            return false;
        }
        var name = msg.get_name();
        var args = Utils.convert_list_to_variant(msg.get_argument_list());
        switch (name) {
        case MsgId.BROWSER_CREATED:
            renderer_created((uint) args[0].get_int64());
            break;
        case MsgId.BROWSER_DESTROYED:
            renderer_destroyed((uint) args[0].get_int64());
            break;
        default:
            message_received(name, args);
            break;
        }
        return true;
    }

    internal bool handle_key_event(Cef.KeyEvent key) {
        if (key.type != Cef.KeyEventType.RAWKEYDOWN) {
            return false;
        }
        var window = get_toplevel() as Gtk.Window;
        if (window == null) {
            return false;
        }

        if (fullscreen) {
            uint keyval = 0;
            var success = Gdk.Keymap.get_default().translate_keyboard_state(
                (uint) key.native_key_code, CefGtk.UIEvents.get_gdk_state_modifiers(key.modifiers), 0,
                out keyval, null, null, null);
            if (success && keyval == Gdk.Key.Escape) {
                toggle_fullscreen(false);
                return true;
            }
        }

        var event = new Gdk.Event(Gdk.EventType.BUTTON_PRESS);
        event.key.hardware_keycode = (uint16) key.native_key_code;
        event.key.state = CefGtk.UIEvents.get_gdk_state_modifiers(key.modifiers);
        return window.activate_key(event.key);
    }

    internal void toggle_fullscreen(bool fullscreen) {
        this.fullscreen = fullscreen;
    }

    private void on_js_dialog_response(Gtk.Dialog dialog, int response_id) {
        Cef.assert_browser_ui_thread();
        dialog.response.disconnect(on_js_dialog_response);
        Cef.String user_input = {};
        switch (js_dialog_type) {
        case Cef.JsdialogType.ALERT:
            js_dialog.destroy();
            js_dialog = null;
            js_dialog_callback.cont(1, &user_input);
            js_dialog_callback = null;
            break;
        default:
            assert_not_reached();
        }
    }

    public Gdk.Pixbuf? get_snapshot() {
        return web_view.get_snapshot();
    }
}

public class RendererExtensionInfo {
    public int browser_id {get; private set;}
    public string path {get; private set;}
    public Variant?[] parameters {get; private set;}

    public RendererExtensionInfo(int browser_id, string path, Variant?[] parameters) {
        this.browser_id = browser_id;
        this.path = path;
        this.parameters = parameters;
    }
}

} // namespace CefGtk
