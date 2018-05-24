namespace CefGtk {

private class WebViewOffscreen : Gtk.DrawingArea, WebViewWidget {
    public double scroll_offset_x {get; internal set; default = 0.0;}
    public double scroll_offset_y {get; internal set; default = 0.0;}
    private unowned WebView web_view;
    private unowned Cef.Browser browser = null;
    Cairo.ImageSurface? surface = null;
    private uint update_source_id = 0;

    public WebViewOffscreen(WebView web_view) {
        this.web_view = web_view;
        set_can_focus(true);
        set_has_window(true);
        set_focus_on_click(true);
        add_events(
            Gdk.EventMask.POINTER_MOTION_MASK
            |Gdk.EventMask.BUTTON_PRESS_MASK
            |Gdk.EventMask.BUTTON_RELEASE_MASK
            |Gdk.EventMask.BUTTON_PRESS_MASK
            |Gdk.EventMask.KEY_PRESS_MASK
            |Gdk.EventMask.KEY_RELEASE_MASK
            |Gdk.EventMask.ENTER_NOTIFY_MASK
            |Gdk.EventMask.LEAVE_NOTIFY_MASK
            |Gdk.EventMask.FOCUS_CHANGE_MASK
            |Gdk.EventMask.SCROLL_MASK
        );
        notify["scale-factor"].connect_after(on_scale_factor_changed);
    }

    ~WebViewOffscreen() {
        notify["scale-factor"].disconnect(on_scale_factor_changed);
    }

    public override void realize() {
        Gtk.Allocation allocation;
        get_allocation(out allocation);
        set_realized(true);
        set_redraw_on_allocate(false);
        base.realize();
        embed_cef();
        update_source_id = Timeout.add(200, () => {
            // FIXME: This is only a workaround.
            if (visible && !web_view.context_menu_visible) {
                browser.get_host().was_hidden((int) true);
                browser.get_host().was_hidden((int) false);
            }
            return true;
        });
    }

    public override void unrealize() {
        Source.remove(update_source_id);
        update_source_id = 0;
        web_view.close_browser(true);
        surface = null;
        base.unrealize();
    }

    public override void show() {
        base.show();
        if (get_realized()) {
            browser.get_host().was_hidden((int) false);
        }
    }

    public override void hide() {
        base.hide();
        if (get_realized()) {
            browser.get_host().was_hidden((int) true);
        }
    }

    public override void size_allocate (Gtk.Allocation allocation) {
        set_allocation(allocation);
        if (browser != null) {
            browser.get_host().was_resized();
        }
        base.size_allocate(allocation);
    }

    private void embed_cef() {
        assert(CefGtk.is_initialized());
        Cef.assert_browser_ui_thread();
        Gtk.Allocation allocation;
        get_allocation(out allocation);
        Cef.WindowInfo window_info = {};
        window_info.parent_window = 0;
        window_info.windowless_rendering_enabled = 1;
        window_info.x = 0;
        window_info.y = 0;
        window_info.width = 0;
        window_info.height = 0;
        Cef.BrowserSettings browser_settings = {sizeof(Cef.BrowserSettings)};
        browser_settings.javascript_access_clipboard = Cef.State.ENABLED;
        browser_settings.javascript_dom_paste = Cef.State.ENABLED;
        browser_settings.universal_access_from_file_urls = Cef.State.ENABLED;
        browser_settings.file_access_from_file_urls = Cef.State.ENABLED;
        browser_settings.windowless_frame_rate = 60 ;
        var client = new Client(
            web_view,
            new FocusHandler(web_view),
            new DisplayHandler(web_view),
            new LoadHandler(web_view),
            new JsdialogHandler(web_view),
            new DownloadHandler(web_view.download_manager),
            new KeyboardHandler(web_view),
            new RequestHandler(web_view),
            new LifeSpanHandler(web_view),
            new RenderHandler(this));
        Cef.String url = {};
        Cef.set_string(&url, "about:blank");
        Cef.Browser browser = Cef.browser_host_create_browser_sync(
            window_info, client, &url, browser_settings, web_view.web_context.request_context);
        this.browser = browser;
        browser_created(client, browser);
    }

    public override bool draw(Cairo.Context cr) {
        if (surface != null) {
            Gdk.Rectangle clip;
            if (!Gdk.cairo_get_clip_rectangle(cr, out clip)) {
                return false;
            }
            cr.save();
            /* The surface is in device pixels, but cairo scale is in logical pixels. */
            int factor = scale_factor;
            cr.scale(1.0 / factor, 1.0 / factor);
            cr.rectangle(factor * clip.x, factor * clip.y, factor * clip.width, factor * clip.height);
            surface.mark_dirty();
            cr.set_source_surface(surface, 0, 0);
            cr.set_operator(Cairo.Operator.OVER);
            cr.fill();
            cr.restore();
        }
        return true;
    }

    internal void paint(Cef.Rect[] dirty_rects, void* buffer, int width, int height) {
        /* Width & height are in device pixels, not logical pixels. */
        if (width <= 2 || height <= 2) {
            surface = null;
            return;
        }
        if (surface == null || surface.get_width() != width || surface.get_height() != height) {
            surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, width, height);
        }
        unowned uint8[] pixels = (uint8[])surface.get_data();
        unowned uint8[] dirty = (uint8[]) buffer;
        int stride = surface.get_stride();
        foreach (unowned Cef.Rect rect in dirty_rects) {
            for (var x = rect.x; x < rect.x + rect.width; x++) {
                for (var y = rect.y; y < rect.y + rect.height; y++) {
                    int cr_pos = y * stride + x * 4;
                    int cef_pos = y * width * 4 + x * 4;
                    pixels[cr_pos + 0] = dirty[cef_pos + 0];
                    pixels[cr_pos + 1] = dirty[cef_pos + 1];
                    pixels[cr_pos + 2] = dirty[cef_pos + 2];
                    pixels[cr_pos + 3] = dirty[cef_pos + 3];
                }
            }
        }
        foreach (unowned Cef.Rect rect in dirty_rects) {
            queue_draw_area(rect.x, rect.y, rect.width, rect.height);
        }
    }

    public override bool button_press_event(Gdk.EventButton event) {
        grab_focus();
        web_view.send_click_event(event);
        return Gdk.EVENT_STOP;
    }

    public override bool button_release_event(Gdk.EventButton event) {
        grab_focus();
        web_view.send_click_event(event);
        return Gdk.EVENT_STOP;
    }

    public override bool motion_notify_event(Gdk.EventMotion event) {
        web_view.send_motion_event(event);
        return Gdk.EVENT_STOP;
    }

    public override bool scroll_event(Gdk.EventScroll event) {
        web_view.send_scroll_event(event);
        return Gdk.EVENT_STOP;
    }

    public override void grab_focus() {
        base.grab_focus();
        web_view.send_focus_toggled(true);
    }

    public override bool focus(Gtk.DirectionType direction) {
        grab_focus();
        return Gdk.EVENT_STOP;
    }

    public override bool focus_in_event(Gdk.EventFocus event) {
        web_view.send_focus_event(event);
        return Gdk.EVENT_STOP;
    }

    public override bool focus_out_event(Gdk.EventFocus event) {
        web_view.send_focus_event(event);
        return Gdk.EVENT_STOP;
    }

    public override bool key_press_event(Gdk.EventKey event) {
        web_view.send_key_event(event);
        return Gdk.EVENT_STOP;
    }

    public override bool key_release_event(Gdk.EventKey event) {
        web_view.send_key_event(event);
        return Gdk.EVENT_STOP;
    }

    public void change_cursor(Cef.CursorHandle cursor, Cef.CursorType type, Cef.CursorInfo? custom_cursor) {
        var window = (Gdk.X11.Window) get_window();
        var display = (Gdk.X11.Display) window.get_display();
        unowned string? name = null;
        switch (type) {
        case Cef.CursorType.POINTER:
            name = "default";
            break;
        case Cef.CursorType.CROSS:
            name = "crosshair";
            break;
        case Cef.CursorType.HAND:
            name = "pointer";
            break;
        case Cef.CursorType.IBEAM:
            name = "text";
            break;
        case Cef.CursorType.WAIT:
            name = "wait";
            break;
        case Cef.CursorType.HELP:
            name = "help";
            break;
        case Cef.CursorType.EASTRESIZE:
        case Cef.CursorType.EASTPANNING:
            name = "e-resize";
            break;
        case Cef.CursorType.NORTHRESIZE:
        case Cef.CursorType.NORTHPANNING:
            name = "n-resize";
            break;
        case Cef.CursorType.NORTHEASTRESIZE:
        case Cef.CursorType.NORTHEASTPANNING:
            name = "ne-resize";
            break;
        case Cef.CursorType.NORTHWESTRESIZE:
        case Cef.CursorType.NORTHWESTPANNING:
            name = "nw-resize";
            break;
        case Cef.CursorType.SOUTHRESIZE:
        case Cef.CursorType.SOUTHPANNING:
            name = "s-resize";
            break;
        case Cef.CursorType.SOUTHEASTRESIZE:
        case Cef.CursorType.SOUTHEASTPANNING:
            name = "se-resize";
            break;
        case Cef.CursorType.SOUTHWESTRESIZE:
        case Cef.CursorType.SOUTHWESTPANNING:
            name = "sw-resize";
            break;
        case Cef.CursorType.WESTRESIZE:
        case Cef.CursorType.WESTPANNING:
            name = "w-resize";
            break;
        case Cef.CursorType.NORTHSOUTHRESIZE:
            name = "ns-resize";
            break;
        case Cef.CursorType.EASTWESTRESIZE:
            name = "ew-resize";
            break;
        case Cef.CursorType.NORTHEASTSOUTHWESTRESIZE:
            name = "nesw-resize";
            break;
        case Cef.CursorType.NORTHWESTSOUTHEASTRESIZE:
            name = "nwse-resize";
            break;
        case Cef.CursorType.COLUMNRESIZE:
            name = "col-resize";
            break;
        case Cef.CursorType.ROWRESIZE:
            name = "row-resize";
            break;
        case Cef.CursorType.MOVE:
        case Cef.CursorType.MIDDLEPANNING:
            name = "move";
            break;
        case Cef.CursorType.VERTICALTEXT:
            name = "vertical-text";
            break;
        case Cef.CursorType.CELL:
            name = "cell";
            break;
        case Cef.CursorType.CONTEXTMENU:
            name = "context-menu";
            break;
        case Cef.CursorType.ALIAS:
            name = "alias";
            break;
        case Cef.CursorType.PROGRESS:
            name = "progress";
            break;
        case Cef.CursorType.NODROP:
            name = "no-drop";
            break;
        case Cef.CursorType.COPY:
            name = "copy";
            break;
        case Cef.CursorType.NONE:
            name = "none";
            break;
        case Cef.CursorType.NOTALLOWED:
            name = "not-allowed";
            break;
        case Cef.CursorType.ZOOMIN:
            name = "zoom-in";
            break;
        case Cef.CursorType.ZOOMOUT:
            name = "zoom-out";
            break;
        case Cef.CursorType.GRAB:
            name = "grab";
            break;
        case Cef.CursorType.GRABBING:
            name = "grabbing";
            break;
        case Cef.CursorType.CUSTOM:
            int width = custom_cursor.size.width;
            int height = custom_cursor.size.height;
            int x = custom_cursor.hotspot.x;
            int y = custom_cursor.hotspot.y;
            unowned uint8[] buffer = (uint8[]) custom_cursor.buffer;
            buffer.length = 4 * width * height;
            var pixbuf = new Gdk.Pixbuf.from_data(buffer, Gdk.Colorspace.RGB, true, 8, width, height, 4 * width);
            window.set_cursor(new Gdk.Cursor.from_pixbuf(display, pixbuf, x, y));
            return;
        default:
            name = "default";
            break;
        }
        if (name != null) {
            window.set_cursor(new Gdk.Cursor.from_name(display, name));
        }
    }

    private void on_scale_factor_changed(GLib.Object o, ParamSpec p) {
        web_view.update_screen_info();
    }
}

} // namespace CefGtk
