namespace CefGtk {

private class WebViewWindowed : Gtk.Widget {
    private Gdk.X11.Window? chromium_window = null;
    private Gdk.X11.Window? cef_window = null;
    private unowned WebView web_view;

    public WebViewWindowed(WebView web_view) {
        this.web_view = web_view;
        set_has_window(true);
        set_can_focus(false);
    }

    public signal void browser_created(Client client, Cef.Browser browser);

    public override void get_preferred_width(out int minimum_width, out int natural_width) {
        minimum_width = natural_width = 100;
    }

    public override void get_preferred_height(out int minimum_height, out int natural_height) {
        minimum_height = natural_height = 100;
    }

    public override void realize() {
        Gtk.Allocation allocation;
        get_allocation(out allocation);
        set_realized(true);

        Gdk.WindowAttr attributes = {};
        attributes.x = allocation.x;
        attributes.y = allocation.y;
        attributes.width = allocation.width;
        attributes.height = allocation.height;
        attributes.window_type = Gdk.WindowType.CHILD;
        attributes.visual = get_visual();
        attributes.wclass = Gdk.WindowWindowClass.INPUT_OUTPUT;
        attributes.event_mask = (get_events()
            | Gdk.EventMask.BUTTON_MOTION_MASK
            | Gdk.EventMask.BUTTON_PRESS_MASK
            | Gdk.EventMask.BUTTON_RELEASE_MASK
            | Gdk.EventMask.EXPOSURE_MASK
            | Gdk.EventMask.ENTER_NOTIFY_MASK
            | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        Gdk.WindowAttributesType attributes_mask = (
            Gdk.WindowAttributesType.X | Gdk.WindowAttributesType.Y | Gdk.WindowAttributesType.VISUAL);

        var window = new Gdk.Window (get_parent_window (), attributes, attributes_mask);
        set_window(window);
        register_window(window);
        embed_cef();
    }

    public override void size_allocate (Gtk.Allocation allocation) {
        Gtk.Allocation child_allocation = {};
        set_allocation(allocation);
        if (!get_has_window()) {
            child_allocation.x = allocation.x;
            child_allocation.y = allocation.y;
        }
        else {
            child_allocation.x = 0;
            child_allocation.y = 0;
        }
        child_allocation.width = allocation.width;
        child_allocation.height = allocation.height;
        if (get_realized() && get_has_window()) {
            debug("allocation %d,%d+%d,%d child_allocation %d,%d+%d,%d",
                allocation.x, allocation.y, allocation.width, allocation.height,
                child_allocation.x, child_allocation.y, child_allocation.width, child_allocation.height);
            get_window().move_resize(allocation.x, allocation.y, child_allocation.width, child_allocation.height);
            cef_window.move_resize(child_allocation.x, child_allocation.y, child_allocation.width, child_allocation.height);
        }
    }

    private void embed_cef() {
        assert(CefGtk.is_initialized());
        Cef.assert_browser_ui_thread();
        var toplevel = get_toplevel();
        assert(toplevel.is_toplevel());
        CefGtk.override_system_visual(toplevel.get_visual());
        var parent_window = get_window() as Gdk.X11.Window;
        assert(parent_window != null);
        Gtk.Allocation allocation;
        get_allocation(out allocation);
        Cef.WindowInfo window_info = {};
        window_info.parent_window = (Cef.WindowHandle) parent_window.get_xid();
        window_info.x = 0;
        window_info.y = 0;
        window_info.width = allocation.width;
        window_info.height = allocation.height;
        Cef.BrowserSettings browser_settings = {sizeof(Cef.BrowserSettings)};
        browser_settings.javascript_access_clipboard = Cef.State.ENABLED;
        browser_settings.javascript_dom_paste = Cef.State.ENABLED;
        browser_settings.universal_access_from_file_urls = Cef.State.ENABLED;
        browser_settings.file_access_from_file_urls = Cef.State.ENABLED;
        var client = new Client(
            web_view,
            new FocusHandler(web_view),
            new DisplayHandler(web_view),
            new LoadHandler(web_view),
            new JsdialogHandler(web_view),
            new DownloadHandler(web_view.download_manager),
            new KeyboardHandler(web_view),
            new RequestHandler(web_view),
            new LifeSpanHandler(web_view));
        Cef.String url = {};
        Cef.set_string(&url, "about:blank");
        Cef.Browser browser = Cef.browser_host_create_browser_sync(
            window_info, client, &url, browser_settings, web_view.web_context.request_context);
        
        var host = browser.get_host();
        cef_window = wrap_xwindow(
            parent_window.get_display() as Gdk.X11.Display, (X.Window) host.get_window_handle());
        cef_window.ensure_native();
        register_window(cef_window);
        chromium_window = find_child_window(cef_window);
        assert(chromium_window != null);
        chromium_window.ensure_native();
        register_window(chromium_window);
        browser_created(client, browser);
    }

    public Gdk.Pixbuf? get_snapshot() {
        Gtk.Allocation allocation;
        get_allocation(out allocation);
        return Gdk.pixbuf_get_from_window(get_window(), 0, 0, allocation.width, allocation.height);
    }
}

} // namespace CefGtk
