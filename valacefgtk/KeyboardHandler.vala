namespace CefGtk {

public class KeyboardHandler : Cef.KeyboardHandlerRef {
    public KeyboardHandler(WebView web_view) {
        base();
        priv_set<unowned WebView>("web_view", web_view);
        
        /**
         * Called before a keyboard event is sent to the renderer. |event| contains
         * information about the keyboard event. |os_event| is the operating system
         * event message, if any. Return true (1) if the event was handled or false
         * (0) otherwise. If the event will be handled in on_key_event() as a keyboard
         * shortcut set |is_keyboard_shortcut| to true (1) and return false (0).
         */
        /*int*/ vfunc_on_pre_key_event = (Cef.KeyboardHandlerOnPreKeyEventFunc) handle;
    }
    
    private static int handle(Cef.KeyboardHandler self, Cef.Browser? browser, Cef.KeyEvent key,
    Cef.EventHandle? os_event, int? is_keyboard_shortcut) {
        Cef.assert_browser_ui_thread();
        return (int) ((Cef.KeyboardHandlerRef) self).priv_get<unowned WebView>("web_view").handle_key_event(key);
    }
}

} // namespace CefGtk
