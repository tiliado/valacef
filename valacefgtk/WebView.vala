namespace CefGtk {

public class WebView : Gtk.Widget {
    public string? title {get; internal set; default = null;}
    public string? uri {get; internal set; default = null;}
    public string? status_message {get; internal set; default = null;}
    public bool can_go_back {get; internal set; default = false;}
    public bool can_go_forward {get; internal set; default = false;}
    public bool is_loading {get; internal set; default = false;}
    public WebContext web_context {get; private set;}
    public double zoom_level {
        get {return (browser != null) ? browser.get_host().get_zoom_level() : 0.0;}
        set {if (browser != null) {browser.get_host().set_zoom_level(value);}}
        }
    private Cef.Browser? browser = null;
    private Client? client = null;
    private Gdk.X11.Window? chromium_window = null;
    private Gdk.X11.Window? cef_window = null;
    private string? uri_to_load = null;
    
    public WebView(WebContext web_context) {
        set_has_window(true);
		set_can_focus(true);
        this.web_context = web_context;
    }
    
    public signal void ready();
    
    public signal void load_started(Cef.TransitionType transition);
    
    public signal void load_ended(int http_status_code);
    
    public signal void load_error(Cef.Errorcode error_code, string? error_text, string? failed_url);
    
    public virtual signal void console_message(string? source, int line, string? text) {
        message("Console: %s:%d: %s", source, line, text);
    }
    
    public bool is_ready() {
        return browser != null;
    }
    
    public void load_uri(string? uri) {
        if (browser != null) {
            Cef.String cef_uri = {};
            Cef.set_string(&cef_uri, uri);
            browser.get_main_frame().load_url(&cef_uri);
        } else {
            uri_to_load = uri;
        }
    }
    
    public void go_back() {
        if (browser != null) {
            browser.go_back();
        }
    }
    
    public void go_forward() {
        if (browser != null) {
            browser.go_forward();
        }
    }
    
    public void reload() {
        if (browser != null) {
            browser.reload();
        }
    }
    
    public void reload_ignore_cache() {
        if (browser != null) {
            browser.reload_ignore_cache();
        }
    }
    
    public void stop_load() {
        if (browser != null) {
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
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.cut();
            }
        }
    }
    
    [Signal (action=true)]
    public void edit_copy() {
        if (browser != null) {
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.copy();
            }
        }
    }
    
    [Signal (action=true)]
    public void edit_paste() {
        if (browser != null) {
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.paste();
            }
        }
    }
    
    [Signal (action=true)]
    public void edit_select_all() {
        if (browser != null) {
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.select_all();
            }
        }
    }
    
    [Signal (action=true)]
    public void edit_undo() {
        if (browser != null) {
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.undo();
            }
        }
    }
    
    [Signal (action=true)]
    public void edit_redo() {
        if (browser != null) {
            var frame = browser.get_focused_frame();
            if (frame != null) {
                frame.redo();
            }
        }
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
		base.grab_focus();
		message("focus");
	}

    public override bool focus_in_event(Gdk.EventFocus event) {
		message("focus_in_event");
		base.focus_in_event(event);
        browser.get_host().send_focus_event(1);
		return false;
	}
	
    public override bool focus_out_event(Gdk.EventFocus event) {
		message("focus_out_event");
		base.focus_out_event(event);
        browser.get_host().send_focus_event(0);
		return false;
	}
    
    
    
    public void send_click_event(Gdk.EventButton event) {
        UIEvents.send_click_event(event, browser.get_host());
    }
    
    public void send_scroll_event(Gdk.EventScroll event) {
        UIEvents.send_scroll_event(event, browser.get_host());
    }
    
    
    public void send_key_event(Gdk.EventKey event) {
        UIEvents.send_key_event(event, browser.get_host());
    }
    
    public void send_motion_event(Gdk.EventMotion event) {
        UIEvents.send_motion_event(event, browser.get_host()); 
    }
    
    private void embed_cef() {
		assert(CefGtk.is_initialized());
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
            new FocusHandler(this),
            new DisplayHandler(this),
            new LoadHandler(this));
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
         send_message("load_renderer_extension", args);
     }
}

} // namespace CefGtk
