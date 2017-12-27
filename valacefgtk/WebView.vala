namespace CefGtk {

public class WebView : Gtk.Widget {
    public string? title {get; internal set; default = null;}
    public string? uri {get; internal set; default = null;}
    public string? status_message {get; internal set; default = null;}
    public bool can_go_back {get; internal set; default = false;}
    public bool can_go_forward {get; internal set; default = false;}
    public bool is_loading {get; internal set; default = false;}
    public WebContext web_context {get; private set;}
    public DownloadManager download_manager {get; private set;}
    public double zoom_level {
        get {
            if (browser == null) {
                return _zoom_level;
            }
            Cef.assert_browser_ui_thread();
            return browser.get_host().get_zoom_level();
        }
        set {
            if (browser == null) {
                _zoom_level = value;
            } else {
                Cef.assert_browser_ui_thread();
                browser.get_host().set_zoom_level(value);
            }
        }
    }
    private double _zoom_level = 0.0;
    private Cef.Browser? browser = null;
    private Client? client = null;
    private Gdk.X11.Window? chromium_window = null;
    private Gdk.X11.Window? cef_window = null;
    private string? uri_to_load = null;
    private Gtk.MessageDialog? js_dialog = null;
    private Cef.JsdialogCallback? js_dialog_callback = null;
    private Cef.JsdialogType js_dialog_type = Cef.JsdialogType.ALERT;
    
    public WebView(WebContext web_context) {
        set_has_window(true);
		set_can_focus(true);
        this.web_context = web_context;
        this.download_manager = new DownloadManager(this);
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
    
    public virtual signal void renderer_created() {
        message("Renderer created.");
    }
    
    public virtual signal void renderer_destroyed() {
        message("Renderer destroyed.");
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
    
    public bool is_ready() {
        return browser != null;
    }
    
    public void load_uri(string? uri) {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            Cef.String cef_uri = {};
            Cef.set_string(&cef_uri, uri);
            browser.get_main_frame().load_url(&cef_uri);
        } else {
            uri_to_load = uri;
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
        zoom_level += 0.5;
    }
    
    [Signal (action=true)]
    public void zoom_out() {
        zoom_level -= 0.5;
    }
    
    [Signal (action=true)]
    public void zoom_reset() {
        zoom_level = 0.0;
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
    
    public override void get_preferred_width(out int minimum_width, out int natural_width) {
        minimum_width = natural_width = 100;
    }
    
    public override void get_preferred_height(out int minimum_height, out int natural_height) {
        minimum_height = natural_height = 100;
    }
    
    public override void realize() {
		embed_cef();
        set_realized(true);
    }
    
    public override void grab_focus() {
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.get_host().send_focus_event(1);
        }
        base.grab_focus();
	}
    
    public override bool focus_in_event(Gdk.EventFocus event) {
		base.focus_in_event(event);
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.get_host().send_focus_event(1);
        }
		return false;
	}
	
    public override bool focus_out_event(Gdk.EventFocus event) {
		base.focus_out_event(event);
        if (browser != null) {
            Cef.assert_browser_ui_thread();
            browser.get_host().send_focus_event(0);
        }
		return false;
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
    
    private void embed_cef() {
		assert(CefGtk.is_initialized());
        Cef.assert_browser_ui_thread();
		var toplevel = get_toplevel();
		assert(toplevel.is_toplevel());
        CefGtk.override_system_visual(toplevel.get_visual());
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
        browser_settings.javascript_access_clipboard = Cef.State.ENABLED;
        browser_settings.javascript_dom_paste = Cef.State.ENABLED;
        client = new Client(
            this,
            new FocusHandler(this),
            new DisplayHandler(this),
            new LoadHandler(this),
            new JsdialogHandler(this),
            new DownloadHandler(download_manager));
        Cef.String url = {};
        Cef.set_string(&url, uri_to_load ?? "about:blank");
        uri_to_load = null;
        browser = Cef.browser_host_create_browser_sync(
            window_info, client, &url, browser_settings, web_context.request_context);
        var host = browser.get_host();
		cef_window = wrap_xwindow(
            parent_window.get_display() as Gdk.X11.Display, (X.Window) host.get_window_handle());
        register_window(cef_window);
        chromium_window = find_child_window(cef_window);
        assert(chromium_window != null);
        register_window(chromium_window);
        set_window(cef_window);
        ready();
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
     
     internal bool on_message_received(Cef.Browser? browser, Cef.ProcessMessage? msg) {
        return_val_if_fail(browser != this.browser, false);
        var name = msg.get_name();
        switch (name) {
        case MsgId.BROWSER_CREATED:
            renderer_created();
            break;
        case MsgId.BROWSER_DESTROYED:
            renderer_destroyed();
            break;
        default:
            var args = Utils.convert_list_to_variant(msg.get_argument_list());
            message_received(name, args);
            break;
        }
        return true;
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
}

} // namespace CefGtk
