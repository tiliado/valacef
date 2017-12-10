namespace CefGtk {

public class WebView : Gtk.Widget {
    private Cef.Browser? browser = null;
    private Client? client = null;
    private Gdk.Window? event_window = null;
    private Gdk.Window? cef_window = null;
    private bool io = true;
    
    public WebView() {
        set_has_window(true);
		set_can_focus(true);
        add_events(Gdk.EventMask.ALL_EVENTS_MASK);
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
            event_window.restack(cef_window, io);
            Timeout.add(100, () => {event_window.restack(cef_window, true); return true;});
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
        return false;
    }
    
    public override bool button_release_event(Gdk.EventButton event) {
        message("button_prelease_event");
        if (!has_focus) {
            grab_focus();
        }
        return false;
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
        Cef.KeyEvent key = {};
        Keyboard.KeyboardCode windows_keycode = Keyboard.gdk_event_to_windows_keycode(event);
        key.windows_key_code = Keyboard.get_windows_keycode_without_location(windows_keycode);
        key.native_key_code = event.hardware_keycode;
        key.modifiers = Keyboard.get_cef_state_modifiers(event.state);
        if (event.keyval >= Gdk.Key.KP_Space && event.keyval <= Gdk.Key.KP_9) {
            key.modifiers |= Cef.EventFlags.IS_KEY_PAD;
        }
        if ((key.modifiers & Cef.EventFlags.ALT_DOWN) != 0) {
            key.is_system_key = 1;
        }
        if (windows_keycode == Keyboard.KeyboardCode.VKEY_RETURN) {
            // We need to treat the enter key as a key press of character \r.  This
            // is apparently just how webkit handles it and what it expects.
            key.unmodified_character = '\r';
        } else {
            // FIXME: fix for non BMP chars
            key.unmodified_character = (Cef.Char16) Gdk.keyval_to_unicode(event.keyval);
        }

        // If ctrl key is pressed down, then control character shall be input.
        if ((key.modifiers & Cef.EventFlags.CONTROL_DOWN) != 0) {
            key.character = (Cef.Char16) Keyboard.get_control_character(
                windows_keycode, (key.modifiers & Cef.EventFlags.SHIFT_DOWN) != 0);
        } else {
            key.character = key.unmodified_character;
        }
        
        var host = browser.get_host();
        if (event.type == Gdk.EventType.KEY_PRESS) {
            key.type = Cef.KeyEventType.RAWKEYDOWN;
            host.send_key_event(key);
            key.type = Cef.KeyEventType.CHAR;
            host.send_key_event(key);
        } else {
            key.type = Cef.KeyEventType.KEYUP;
            host.send_key_event(key);
        }
    }
    
    public override void size_allocate(Gtk.Allocation allocation) {
        base.size_allocate(allocation);
        if (event_window != null && cef_window != null) {
            cef_window.move_resize(allocation.x, allocation.y, allocation.width, allocation.height);
            event_window.restack(cef_window, true);
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
        client = new Client(new FocusHandler(this));
        Cef.String url = {};
        Cef.set_string(ref url, "https://www.google.com");
        browser = Cef.browser_host_create_browser_sync(window_info, client, ref url, browser_settings, null);
        var host = browser.get_host();
        host.set_focus(io ? 0 : 1);
		return new Gdk.X11.Window.foreign_for_display(
			parent_window.get_display() as Gdk.X11.Display, (X.Window) host.get_window_handle());
    }
}

} // namespace CefGtk
