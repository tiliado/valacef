namespace CefGtk {

public class DisplayHandler : Cef.DisplayHandlerRef {
    public DisplayHandler(WebView web_view) {
        base();
        priv_set<unowned WebView>("web_view", web_view);
        
        /**
         * Called when a frame's address has changed.
         */
        /*void*/ vfunc_on_address_change = (self, /*Browser*/ browser, /*Frame*/ frame, /*String*/ url) => {
        };

        /**
         * Called when the page title changes.
         */
        /*void*/ vfunc_on_title_change = (self, /*Browser*/ browser, /*String*/ title) => {
            get_web_view(self).title = Cef.get_string(title);
        };

        /**
         * Called when the page icon changes.
         */
        /*void*/ vfunc_on_favicon_urlchange = (self, /*Browser*/ browser, /*StringList*/ icon_urls) => {
        };

        /**
         * Called when web content in the page has toggled fullscreen mode. If
         * |fullscreen| is true (1) the content will automatically be sized to fill
         * the browser content area. If |fullscreen| is false (0) the content will
         * automatically return to its original size and position. The client is
         * responsible for resizing the browser if desired.
         */
        /*void*/ vfunc_on_fullscreen_mode_change = (self, /*Browser*/ browser, /*int*/ fullscreen) => {
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
            return 0;
        };

        /**
         * Called when the browser receives a status message. |value| contains the
         * text that will be displayed in the status message.
         */
        /*void*/ vfunc_on_status_message = (self, /*Browser*/ browser, /*String*/ value) => {
        };

        /**
         * Called to display a console message. Return true (1) to stop the message
         * from being output to the console.
         */
        /*int*/ vfunc_on_console_message = (self, /*Browser*/ browser, /*String*/ message, /*String*/ source,
        /*int*/ line) => {
            return 0;
        };
    
    }
    
    private static unowned WebView get_web_view(Cef.DisplayHandler self) {
        return ((Cef.DisplayHandlerRef)self).priv_get<unowned WebView>("web_view");
    }
}

} // namespace CefGtk
