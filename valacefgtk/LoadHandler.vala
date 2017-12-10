namespace CefGtk {

public class LoadHandler : Cef.LoadHandlerRef {
    public LoadHandler(WebView web_view) {
        base();
        priv_set<unowned WebView>("web_view", web_view);
        
        /**
         * Called when the loading state has changed. This callback will be executed
         * twice -- once when loading is initiated either programmatically or by user
         * action, and once when loading is terminated due to completion, cancellation
         * of failure. It will be called before any calls to OnLoadStart and after all
         * calls to OnLoadError and/or OnLoadEnd.
         */
        /*void*/ vfunc_on_loading_state_change = (self, /*Browser*/ browser, /*int*/ is_loading, /*int*/ can_go_back,
        /*int*/ can_go_forward) => {
            var web = get_web_view(self);
            web.can_go_back = (bool) can_go_back;
            web.can_go_forward = (bool) can_go_forward;
            web.is_loading = (bool) is_loading;
        };

        /**
         * Called after a navigation has been committed and before the browser begins
         * loading contents in the frame. The |frame| value will never be NULL -- call
         * the is_main() function to check if this frame is the main frame.
         * |transition_type| provides information about the source of the navigation
         * and an accurate value is only available in the browser process. Multiple
         * frames may be loading at the same time. Sub-frames may start or continue
         * loading after the main frame load has ended. This function will not be
         * called for same page navigations (fragments, history state, etc.) or for
         * navigations that fail or are canceled before commit. For notification of
         * overall browser load status use OnLoadingStateChange instead.
         */
        /*void*/ vfunc_on_load_start = (self, /*Browser*/ browser, /*Frame*/ frame, /*TransitionType*/ transition_type
        ) => {
            if (frame.is_main() == 1) {
                get_web_view(self).load_started(transition_type);
            }
        };

        /**
         * Called when the browser is done loading a frame. The |frame| value will
         * never be NULL -- call the is_main() function to check if this frame is the
         * main frame. Multiple frames may be loading at the same time. Sub-frames may
         * start or continue loading after the main frame load has ended. This
         * function will not be called for same page navigations (fragments, history
         * state, etc.) or for navigations that fail or are canceled before commit.
         * For notification of overall browser load status use OnLoadingStateChange
         * instead.
         */
        /*void*/ vfunc_on_load_end = (self, /*Browser*/ browser, /*Frame*/ frame, /*int*/ http_status_code) => {
            if (frame.is_main() == 1) {
                get_web_view(self).load_ended(http_status_code);
            }
        };
        
        /**
         * Called when a navigation fails or is canceled. This function may be called
         * by itself if before commit or in combination with OnLoadStart/OnLoadEnd if
         * after commit. |errorCode| is the error code number, |errorText| is the
         * error text and |failedUrl| is the URL that failed to load. See
         * net\base\net_error_list.h for complete descriptions of the error codes.
         */
        /*void*/ vfunc_on_load_error = (self, /*Browser*/ browser, /*Frame*/ frame, /*Errorcode*/ error_code,
        /*String*/ error_text, /*String*/ failed_url) => {
            if (frame.is_main() == 1) {
                get_web_view(self).load_error(error_code, Cef.get_string(error_text), Cef.get_string(failed_url));
            }
        };
    
    }
    
    private static unowned WebView get_web_view(Cef.LoadHandler self) {
        return ((Cef.LoadHandlerRef)self).priv_get<unowned WebView>("web_view");
    }
}

} // namespace CefGtk
