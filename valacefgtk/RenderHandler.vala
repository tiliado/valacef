namespace CefGtk {

private class RenderHandler : Cef.RenderHandlerRef {
    public RenderHandler(WebViewOffscreen web_view) {
        base();
        priv_set<unowned WebViewOffscreen>("web_view", web_view);

        /**
         * Return the handler for accessibility notifications. If no handler is
         * provided the default implementation will be used.
         */
        /*AccessibilityHandler*/ vfunc_get_accessibility_handler = (self) => {return null;};

        /**
         * Called to retrieve the root window rectangle in screen coordinates. Return
         * true (1) if the rectangle was provided.
         */
        /*int*/ vfunc_get_root_screen_rect = (self, /*Browser*/ browser, /*Rect?*/ rect) => {
            return 0;
        };

        /**
         * Called to retrieve the view rectangle which is relative to screen
         * coordinates. This function must always provide a non-NULL rectangle.
         */
        /*void*/ vfunc_get_view_rect = (self, /*Browser*/ browser, /*Rect?*/ rect) => {
            ((RenderHandler) self).set_rect_from_allocation(rect);
        };

        /**
         * Called to retrieve the translation from view coordinates to actual screen
         * coordinates. Return true (1) if the screen coordinates were provided.
         */

        /*int*/ vfunc_get_screen_point = (
            self, /*Browser*/ browser, /*int*/ viewX, /*int*/ viewY, /*int*/ ref screenX, /*int*/ ref screenY
        ) => {
            ((RenderHandler) self).get_screen_coords(viewX, viewY, ref screenX,  ref screenY);
            return 1;
        };
        /**
         * Called to allow the client to fill in the CefScreenInfo object with
         * appropriate values. Return true (1) if the |screen_info| structure has been
         * modified.
         *
         * If the screen info rectangle is left NULL the rectangle from GetViewRect
         * will be used. If the rectangle is still NULL or invalid popups may not be
         * drawn correctly.
         */
        /*int*/ vfunc_get_screen_info = (self, /*Browser*/ browser, /*ScreenInfo*/ screen_info) => {
            unowned WebViewOffscreen view = ((RenderHandler) self).priv_get<unowned WebViewOffscreen>("web_view");
            screen_info.device_scale_factor = 1.0f * view.scale_factor;
            ((RenderHandler) self).set_rect_from_allocation(screen_info.rect);
            ((RenderHandler) self).set_rect_from_allocation(screen_info.available_rect);
            return 1;
        };

        /**
         * Called when the browser wants to show or hide the popup widget. The popup
         * should be shown if |show| is true (1) and hidden if |show| is false (0).
         */
        /*void*/ vfunc_on_popup_show = (self, /*Browser*/ browser, /*int*/ show) => {
            message("vfunc_on_popup_show %d", show);
        };

        /**
         * Called when the browser wants to move or resize the popup widget. |rect|
         * contains the new location and size in view coordinates.
         */
        /*void*/ vfunc_on_popup_size = (self, /*Browser*/ browser, /*Rect*/ rect) => {
            message("vfunc_on_popup_size");
        };

        /**
         * Called when an element should be painted. Pixel values passed to this
         * function are scaled relative to view coordinates based on the value of
         * CefScreenInfo.device_scale_factor returned from GetScreenInfo. |type|
         * indicates whether the element is the view or the popup widget. |buffer|
         * contains the pixel data for the whole image. |dirtyRects| contains the set
         * of rectangles in pixel coordinates that need to be repainted. |buffer| will
         * be |width|*|height|*4 bytes in size and represents a BGRA image with an
         * upper-left origin.
         */
        /*void*/ vfunc_on_paint = (
            self, /*Browser*/ browser, /*PaintElementType*/ type, /*Rect[]*/ dirtyRects, /*void*/ buffer,
            /*int*/ width, /*int*/ height
        ) => {
            ((RenderHandler) self).priv_get<unowned WebViewOffscreen>("web_view").paint(
                dirtyRects, buffer, width, height);
        };

        /**
         * Called when the browser's cursor has changed. If |type| is CT_CUSTOM then
         * |custom_cursor_info| will be populated with the custom cursor information.
         */
        // ! /*void*/ vfunc_on_cursor_change = (
        // !     self, /*Browser*/ browser, /*CursorHandle*/ cursor, /*CursorType*/ type, /*CursorInfo*/ custom_cursor
        // ! ) => {
        // !     ((RenderHandler) self).priv_get<unowned WebViewOffscreen>("web_view").change_cursor(
        // !         cursor, type, custom_cursor);
        // ! };

        /**
         * Called when the user starts dragging content in the web view. Contextual
         * information about the dragged content is supplied by |drag_data|. (|x|,
         * |y|) is the drag start location in screen coordinates. OS APIs that run a
         * system message loop may be used within the StartDragging call.
         *
         * Return false (0) to abort the drag operation. Don't call any of
         * cef_browser_host_t::DragSource*Ended* functions after returning false (0).
         *
         * Return true (1) to handle the drag operation. Call
         * cef_browser_host_t::DragSourceEndedAt and DragSourceSystemDragEnded either
         * synchronously or asynchronously to inform the web view that the drag
         * operation has ended.
         */
        /*int*/ vfunc_start_dragging = (
            self, /*Browser*/ browser, /*DragData*/ drag_data, /*DragOperationsMask*/ allowed_ops, /*int*/ x, /*int*/ y
        ) => {
            message("vfunc_start_dragging");
            return 0;
        };

        /**
         * Called when the web view wants to update the mouse cursor during a drag &
         * drop operation. |operation| describes the allowed operation (none, move,
         * copy, link).
         */
        /*void*/ vfunc_update_drag_cursor = (self, /*Browser*/ browser, /*DragOperationsMask*/ operation) => {
            message("vfunc_update_drag_cursor");
        };

        /**
         * Called when the scroll offset has changed.
         */
        /*void*/ vfunc_on_scroll_offset_changed = (self, /*Browser*/ browser, /*double*/ x, /*double*/ y) => {
            unowned WebViewOffscreen view = ((RenderHandler) self).priv_get<unowned WebViewOffscreen>("web_view");
            view.scroll_offset_x = x;
            view.scroll_offset_y = y;
        };

        /**
         * Called when the IME composition range has changed. |selected_range| is the
         * range of characters that have been selected. |character_bounds| is the
         * bounds of each character in view coordinates.
         */
        /*void*/ vfunc_on_ime_composition_range_changed = (
            self, /*Browser*/ browser, /*Range*/ selected_range, /*Rect[]*/ character_bounds
        ) => {
            message("vfunc_on_ime_composition_range_changed");
        };

        /**
         * Called when text selection has changed for the specified |browser|.
         * |selected_text| is the currently selected text and |selected_range| is the
         * character range.
         */
        /*void*/ vfunc_on_text_selection_changed = (
            self, /*Browser*/ browser, /*String*/ selected_text, /*Range*/ selected_range
        ) => {
            message("vfunc_on_text_selection_changed");
        };
    }

    public void set_rect_from_allocation(Cef.Rect? rect) {
        Gtk.Allocation alloc;
        unowned WebViewOffscreen view = priv_get<unowned WebViewOffscreen>("web_view");
        view.get_allocation(out alloc);
        rect.x = rect.y = 0;
        rect.width = alloc.width;
        rect.height = alloc.height;
    }

    public void get_screen_coords(int x, int y, ref int screen_x, ref int screen_y) {
        unowned WebViewOffscreen view = priv_get<unowned WebViewOffscreen>("web_view");
        Gdk.Window? window = view.get_window();
        assert (window != null);
        window.get_root_coords(x, y, out screen_x, out screen_y);
        screen_x *= view.scale_factor;
        screen_y *= view.scale_factor;
    }
}

} // namespace CefGtk
