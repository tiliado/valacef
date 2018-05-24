namespace CefGtk {

public class ContextMenuHandler : Cef.ContextMenuHandlerRef {
    public ContextMenuHandler(WebView web_view) {
        base();
        priv_set<unowned WebView>("web_view", web_view);

        /**
         * Called before a context menu is displayed. |params| provides information
         * about the context menu state. |model| initially contains the default
         * context menu. The |model| can be cleared to show no context menu or
         * modified to show a custom menu. Do not keep references to |params| or
         * |model| outside of this callback.
         */
        /*void*/ vfunc_on_before_context_menu = (
            self, /*Browser*/ browser, /*Frame*/ frame, /*ContextMenuParams*/ parameters, /*MenuModel*/ model
        ) => {};

        /**
         * Called to allow custom display of the context menu. |params| provides
         * information about the context menu state. |model| contains the context menu
         * model resulting from OnBeforeContextMenu. For custom display return true
         * (1) and execute |callback| either synchronously or asynchronously with the
         * selected command ID. For default display return false (0). Do not keep
         * references to |params| or |model| outside of this callback.
         */
        /*int*/ vfunc_run_context_menu = (
            self, /*Browser*/ browser, /*Frame*/ frame, /*ContextMenuParams*/ parameters, /*MenuModel*/ model,
            /*RunContextMenuCallback*/ callback
        ) => {
            ((Cef.ContextMenuHandlerRef) self).priv_get<unowned WebView>("web_view").context_menu_visible = true;
            return 0;
        };

        /**
         * Called to execute a command selected from the context menu. Return true (1)
         * if the command was handled or false (0) for the default implementation. See
         * cef_menu_id_t for the command ids that have default implementations. All
         * user-defined command ids should be between MENU_ID_USER_FIRST and
         * MENU_ID_USER_LAST. |params| will have the same values as what was passed to
         * on_before_context_menu(). Do not keep a reference to |params| outside of
         * this callback.
         */
        /*int*/ vfunc_on_context_menu_command = (
            self, /*Browser*/ browser, /*Frame*/ frame, /*ContextMenuParams*/ parameters, /*int*/ command_id,
            /*EventFlags*/ event_flags
        ) => {
            return 0;
        };

        /**
         * Called when the context menu is dismissed irregardless of whether the menu
         * was NULL or a command was selected.
         */
        /*void*/ vfunc_on_context_menu_dismissed = (self, /*Browser*/ browser, /*Frame*/ frame) => {
            ((Cef.ContextMenuHandlerRef) self).priv_get<unowned WebView>("web_view").context_menu_visible = false;
        };
    }
}

} // namespace CefGtk
