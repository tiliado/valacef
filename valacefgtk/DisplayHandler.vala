namespace CefGtk {

public class DisplayHandler : Cef.DisplayHandlerRef {
    public DisplayHandler(WebView web_view) {
        base();
        priv_set<unowned WebView>("web_view", web_view);
        
        /**
         * Called when a frame's address has changed.
         */
        /*void*/ vfunc_on_address_change = (self, /*Browser*/ browser, /*Frame*/ frame, /*String*/ url) => {
            Cef.assert_browser_ui_thread();
            if (frame.is_main() == 1) {
                var uri = Cef.get_string(url);
                get_web_view(self).uri = uri != "" && uri != "about:blank" ? uri : null;
            }
        };

        /**
         * Called when the page title changes.
         */
        /*void*/ vfunc_on_title_change = (self, /*Browser*/ browser, /*String*/ title) => {
            Cef.assert_browser_ui_thread();
            get_web_view(self).title = Cef.get_string(title);
        };

        /**
         * Called when the page icon changes.
         */
        /*void*/ vfunc_on_favicon_urlchange = (self, /*Browser*/ browser, /*StringList*/ icon_urls) => {};

        /**
         * Called when web content in the page has toggled fullscreen mode. If
         * |fullscreen| is true (1) the content will automatically be sized to fill
         * the browser content area. If |fullscreen| is false (0) the content will
         * automatically return to its original size and position. The client is
         * responsible for resizing the browser if desired.
         */
        /*void*/ vfunc_on_fullscreen_mode_change = (self, /*Browser*/ browser, /*int*/ fullscreen) => {
            get_web_view(self).toggle_fullscreen((bool) fullscreen);
        };

        /**
         * Called when the browser is about to display a tooltip. |text| contains the
         * text that will be displayed in the tooltip. To handle the display of the
         * tooltip yourself return true (1). Otherwise, you can optionally modify
         * |text| and then return false (0) to allow the browser to display the
         * tooltip. When window rendering is disabled the application is responsible
         * for drawing tooltips and the return value is ignored.
         */
        /*int*/ vfunc_on_tooltip = (self, /*Browser*/ browser, /*String*/ text) => {
            Cef.assert_browser_ui_thread();
            message("Tooltip: %s", Cef.get_string(text));
            return 0;
        };

        /**
         * Called when the browser receives a status message. |value| contains the
         * text that will be displayed in the status message.
         */
        /*void*/ vfunc_on_status_message = (self, /*Browser*/ browser, /*String*/ status_message) => {
            Cef.assert_browser_ui_thread();
            get_web_view(self).status_message = Cef.get_string(status_message);
        };

        /**
         * Called to display a console message. Return true (1) to stop the message
         * from being output to the console.
         */
        /*int*/ vfunc_on_console_message = (self, /*Browser*/ browser, /*LogSeverity*/ severity, /*String*/ text,
        /*String*/ source, /*int*/ line) => {
            Cef.assert_browser_ui_thread();
            get_web_view(self).console_message(Cef.get_string(source), line, Cef.get_string(text));
            return 0;
        };
    
    }
    
    private static unowned WebView get_web_view(Cef.DisplayHandler self) {
        return ((Cef.DisplayHandlerRef)self).priv_get<unowned WebView>("web_view");
    }
}

} // namespace CefGtk
