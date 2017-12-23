namespace CefGtk {

public class Client : Cef.ClientRef {
    public Client(WebView web_view, FocusHandler focus_handler, DisplayHandler display_handler,
    LoadHandler load_handler, JsdialogHandler js_dialog_handler) {
        base();
        priv_set<unowned WebView>("web_view", web_view);
        priv_set("focus_handler", focus_handler);
        priv_set("display_handler", display_handler);
        priv_set("load_handler", load_handler);
        priv_set("js_dialog_handler", js_dialog_handler);
        
        /**
         * Return the handler for context menus. If no handler is provided the default
         * implementation will be used.
         */
        vfunc_get_context_menu_handler = (self) => {
            message("vfunc_get_context_menu_handler");
            return null;
        };

        /**
         * Return the handler for dialogs. If no handler is provided the default
         * implementation will be used.
         */
        vfunc_get_dialog_handler = (self) => {
            message("get_dialog_handler");
            return null;
        };

        /**
         * Return the handler for browser display state events.
         */
        vfunc_get_display_handler = (self) => {
            return ((Cef.ClientRef?)self).priv_get<Cef.DisplayHandler?>("display_handler");
        };

        /**
         * Return the handler for download events. If no handler is returned downloads
         * will not be allowed.
         */
        vfunc_get_download_handler = (self) => {
            message("get_download_handler");
            return null;
        };

        /**
         * Return the handler for drag events.
         */
        vfunc_get_drag_handler = (self) => {
            message("get_drag_handler");
            return null;
        };

        /**
         * Return the handler for find result events.
         */
        vfunc_get_find_handler = (self) => {
            message("get_find_handler");
            return null;
        };

        /**
         * Return the handler for focus events.
         */
        vfunc_get_focus_handler = (self) => {
            return ((Cef.ClientRef?)self).priv_get<Cef.FocusHandler?>("focus_handler");
        };

        /**
         * Return the handler for geolocation permissions requests. If no handler is
         * provided geolocation access will be denied by default.
         */
        vfunc_get_geolocation_handler = (self) => {
            message("get_geolocation_handler");
            return null;
        };

        /**
         * Return the handler for JavaScript dialogs. If no handler is provided the
         * default implementation will be used.
         */
        vfunc_get_jsdialog_handler = (self) => {
            return ((Cef.ClientRef?)self).priv_get<Cef.JsdialogHandler?>("js_dialog_handler");
        };

        /**
         * Return the handler for keyboard events.
         */
        vfunc_get_keyboard_handler = (self) => {
            return new KeyboardHandler();
        };

        /**
         * Return the handler for browser life span events.
         */
        vfunc_get_life_span_handler = (self) => {
            message("get_life_span_handler");
            return null;
        };

        /**
         * Return the handler for browser load status events.
         */
        vfunc_get_load_handler = (self) => {
            return ((Cef.ClientRef?)self).priv_get<Cef.LoadHandler?>("load_handler");
        };

        /**
         * Return the handler for off-screen rendering events.
         */
        vfunc_get_render_handler = (self) => {
            message("get_render_handler");
            return null;
        };
        
        /**
         * Return the handler for browser request events.
         */
        vfunc_get_request_handler = (self) => {
            return null;
        };
        /**
         * Called when a new message is received from a different process. Return true
         * (1) if the message was handled or false (0) otherwise. Do not keep a
         * reference to or attempt to access the message outside of this callback.
         */
        vfunc_on_process_message_received = (self, browser, source_process, msg) => {
            return (int) ((Cef.ClientRef?) self).priv_get<unowned WebView>("web_view").on_message_received(
                browser, msg);
        };
    }
}

} // namespace CefGtk
