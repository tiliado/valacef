namespace CefGtk {

public class AboutBlankPopupClient : Cef.ClientRef {
    public AboutBlankPopupClient(WebView web_view) {
        base();
        priv_set<unowned WebView>("web_view", web_view);
        priv_set("request_handler", new AboutBlankPopupRequestHandler(web_view, this));
        
        /**
         * Return the handler for context menus. If no handler is provided the default
         * implementation will be used.
         */
        vfunc_get_context_menu_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for dialogs. If no handler is provided the default
         * implementation will be used.
         */
        vfunc_get_dialog_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for browser display state events.
         */
        vfunc_get_display_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for download events. If no handler is returned downloads
         * will not be allowed.
         */
        vfunc_get_download_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for drag events.
         */
        vfunc_get_drag_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for find result events.
         */
        vfunc_get_find_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for focus events.
         */
        vfunc_get_focus_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for JavaScript dialogs. If no handler is provided the
         * default implementation will be used.
         */
        vfunc_get_jsdialog_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for keyboard events.
         */
        vfunc_get_keyboard_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for browser life span events.
         */
        vfunc_get_life_span_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for browser load status events.
         */
        vfunc_get_load_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };

        /**
         * Return the handler for off-screen rendering events.
         */
        vfunc_get_render_handler = (self) => {
            Cef.assert_browser_ui_thread();
            return null;
        };
        
        /**
         * Return the handler for browser request events.
         */
        vfunc_get_request_handler = (self) => {
            assert(Cef.currently_on(Cef.ThreadId.UI) + Cef.currently_on(Cef.ThreadId.IO) == 1);
            return ((Cef.ClientRef?)self).priv_get<Cef.RequestHandler?>("request_handler");
        };
        /**
         * Called when a new message is received from a different process. Return true
         * (1) if the message was handled or false (0) otherwise. Do not keep a
         * reference to or attempt to access the message outside of this callback.
         */
        vfunc_on_process_message_received = (self, browser, source_process, msg) => {
            return 0;
        };
    }

    public void navigation_request(NavigationRequest request) {
        // Track only the first navigation from about:blank
        priv_del("request_handler");
        if (!request.allowed) {
            // Close empty pop-up window
            Timeout.add(50, () => {
                request.browser.get_host().close_browser(1);
                return false;
            });
        }
    }
}

} // namespace CefGtk
