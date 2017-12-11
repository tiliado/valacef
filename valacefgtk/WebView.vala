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
    private Gdk.Window? event_window = null;
    private Gdk.Window? cef_window = null;
    private bool io = true;
    private string? uri_to_load = null;
    
    public WebView(WebContext web_context) {
        set_has_window(true);
		set_can_focus(true);
        add_events(Gdk.EventMask.ALL_EVENTS_MASK);
        this.web_context = web_context;
    }
    
    public signal void load_started(Cef.TransitionType transition);
    
    public signal void load_ended(int http_status_code);
    
    public signal void load_error(Cef.Errorcode error_code, string? error_text, string? failed_url);
    
    public virtual signal void console_message(string? source, int line, string? text) {
        message("Console: %s:%d: %s", source, line, text);
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
    
    public void zoom_in() {
        zoom_level += 0.5;
    }
    
    public void zoom_out() {
        zoom_level -= 0.5;
    }
    
    public void zoom_reset() {
        zoom_level = 0.0;
    }
    
    public override void get_preferred_width(out int minimum_width, out int natural_width) {
        minimum_width = natural_width = 100;
    }
    
    public override void get_preferred_height(out int minimum_height, out int natural_height) {
        minimum_height = natural_height = 100;
    }
    
    public override void realize() {
		cef_window = embed_cef();
        register_window(cef_window);
        
        Gtk.Allocation allocation;
        Gdk.WindowAttr attributes = {};
        get_allocation(out allocation);
        attributes.x = allocation.x;
        attributes.y = allocation.y;
        attributes.width = allocation.width;
        attributes.height = allocation.height;
        attributes.window_type = Gdk.WindowType.CHILD;
        attributes.visual = get_visual();
        attributes.event_mask = get_events()
                        | Gdk.EventMask.BUTTON_PRESS_MASK
                        | Gdk.EventMask.BUTTON_RELEASE_MASK
                        | Gdk.EventMask.KEY_PRESS_MASK
                        | Gdk.EventMask.KEY_RELEASE_MASK
                        | Gdk.EventMask.EXPOSURE_MASK
                        | Gdk.EventMask.ENTER_NOTIFY_MASK
                        | Gdk.EventMask.LEAVE_NOTIFY_MASK;
//~       attributes.wclass = Gdk.WindowWindowClass.INPUT_OUTPUT;
      attributes.wclass = Gdk.WindowWindowClass.INPUT_ONLY;
      
        if (io) {
            event_window = new Gdk.Window(
                get_parent_window(), attributes,
                Gdk.WindowAttributesType.X|Gdk.WindowAttributesType.Y/*|Gdk.WindowAttributesType.VISUAL*/);
            register_window(event_window);
            event_window.add_filter(() => Gdk.FilterReturn.CONTINUE);  // Necessary!
        }
        set_window(io ? event_window : cef_window);
        set_realized(true);
    }
    
    public override void grab_focus() {
		base.grab_focus();
		message("focus");
		if (!io && browser != null) {
            browser.get_host().set_focus(1);   
        }
	}
	
	public override bool grab_broken_event (Gdk.EventGrabBroken event) {
		message("Grab broken");
		return false;
	}

    public override bool focus_in_event(Gdk.EventFocus event) {
		message("focus_in_event");
		base.focus_in_event(event);
		return false;
	}
	
    public override bool focus_out_event(Gdk.EventFocus event) {
		message("focus_out_event");
		base.focus_out_event(event);
		return false;
	}
    
    public override bool button_press_event(Gdk.EventButton event) {
        message("button_press_event");
        if (!has_focus) {
            grab_focus();
        }
        send_click_event(event);
        return false;
    }
    
    public override bool button_release_event(Gdk.EventButton event) {
        message("button_prelease_event");
        if (!has_focus) {
            grab_focus();
        }
        send_click_event(event);
        return false;
    }
    
    public void send_click_event(Gdk.EventButton event) {
        UIEvents.send_click_event(event, browser.get_host());
    }
    
    public override bool scroll_event(Gdk.EventScroll event) {
        send_scroll_event(event);
        return false;
    }
    
    public void send_scroll_event(Gdk.EventScroll event) {
        UIEvents.send_scroll_event(event, browser.get_host());
    }
    
    public override bool key_press_event(Gdk.EventKey event) {
        send_key_event(event);
        return false;
    }
    
    public override bool key_release_event(Gdk.EventKey event) {
        send_key_event(event);
        return false;
    }
    
    public void send_key_event(Gdk.EventKey event) {
        UIEvents.send_key_event(event, browser.get_host());
    }
    
    public override bool motion_notify_event(Gdk.EventMotion event) {
        send_motion_event(event);
        return false;
    }
    
    public void send_motion_event(Gdk.EventMotion event) {
        UIEvents.send_motion_event(event, browser.get_host()); 
    }
    
    public override void size_allocate(Gtk.Allocation allocation) {
        base.size_allocate(allocation);
        if (event_window != null && cef_window != null) {
            cef_window.move_resize(allocation.x, allocation.y, allocation.width, allocation.height);
        }
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
        client = new Client(
            new FocusHandler(this),
            new DisplayHandler(this),
            new LoadHandler(this));
        Cef.String url = {};
        Cef.set_string(&url, uri_to_load ?? "about:blank");
        uri_to_load = null;
        browser = Cef.browser_host_create_browser_sync(window_info, client, &url, browser_settings, web_context.request_context);
        var host = browser.get_host();
        host.set_focus(io ? 0 : 1);
		return new Gdk.X11.Window.foreign_for_display(
			parent_window.get_display() as Gdk.X11.Display, (X.Window) host.get_window_handle());
    }
}

} // namespace CefGtk
