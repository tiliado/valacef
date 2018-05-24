namespace CefGtk {

public class JsdialogHandler: Cef.JsdialogHandlerRef {
    public JsdialogHandler(WebView web_view) {
        base();
        priv_set("web_view", web_view);
        
        /**
         * Called to run a JavaScript dialog. If |origin_url| is non-NULL it can be
         * passed to the CefFormatUrlForSecurityDisplay function to retrieve a secure
         * and user-friendly display string. The |default_prompt_text| value will be
         * specified for prompt dialogs only. Set |suppress_message| to true (1) and
         * return false (0) to suppress the message (suppressing messages is
         * preferable to immediately executing the callback as this is used to detect
         * presumably malicious behavior like spamming alert messages in
         * onbeforeunload). Set |suppress_message| to false (0) and return false (0)
         * to use the default implementation (the default implementation will show one
         * modal dialog at a time and suppress any additional dialog requests until
         * the displayed dialog is dismissed). Return true (1) if the application will
         * use a custom dialog or if the callback has been executed immediately.
         * Custom dialogs may be either modal or modeless. If a custom dialog is used
         * the application must execute |callback| once the custom dialog is
         * dismissed.
         */
        /*int*/ vfunc_on_jsdialog = (self, /*Browser*/ browser, /*String*/ url, /*JsdialogType*/ dialog_type,
        /*String*/ message_text, /*String*/ default_prompt_text, /*JsdialogCallback*/ callback,
        /*int*/ ref suppress_message) => {
            Cef.assert_browser_ui_thread();
            message("Show JS dialog for %s", dialog_type.to_string());
            var _web_view = get_web_view(self);
            var _handled = false;
            var _url = Cef.get_string(url);
            var _message_text = Cef.get_string(message_text);
            var _default_prompt_text = Cef.get_string(default_prompt_text);
            switch (dialog_type) {
            case Cef.JsdialogType.ALERT:
                _web_view.alert_dialog(ref _handled, _url, _message_text, callback);
                return (int) _handled;
            case Cef.JsdialogType.CONFIRM:
                _web_view.confirm_dialog(ref _handled, _url, _message_text, callback);
                return (int) _handled;
            case Cef.JsdialogType.PROMPT:
                _web_view.prompt_dialog(ref _handled, _url, _message_text, _default_prompt_text, callback);
                return (int) _handled;
            default:
                return 0;
            }
        };

        /**
         * Called to run a dialog asking the user if they want to leave a page. Return
         * false (0) to use the default dialog implementation. Return true (1) if the
         * application will use a custom dialog or if the callback has been executed
         * immediately. Custom dialogs may be either modal or modeless. If a custom
         * dialog is used the application must execute |callback| once the custom
         * dialog is dismissed.
         */
        /*int*/ vfunc_on_before_unload_dialog = (self, /*Browser*/ browser, /*String*/ message_text, /*int*/ is_reload,
        /*JsdialogCallback*/ callback) => {
            Cef.assert_browser_ui_thread();
            callback.cont(1, null);
            return 1;
        };

        /**
         * Called to cancel any pending dialogs and reset any saved dialog state. Will
         * be called due to events like page navigation irregardless of whether any
         * dialogs are currently pending.
         */
        /*void*/ vfunc_on_reset_dialog_state = (self, /*Browser*/ browser) => {
            Cef.assert_browser_ui_thread();
            get_web_view(self).discard_js_dialogs();
        };

        /**
         * Called when the default implementation dialog is closed.
         */
        // /*void*/ on_dialog_closed = (self, owned Browser? browser);
    }
    
    private static WebView get_web_view(Cef.JsdialogHandler self) {
        return ((Cef.JsdialogHandlerRef) self).priv_get<WebView>("web_view");
    }
}

} // namespace CefGtk
