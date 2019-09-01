namespace CefGtk {

public class AboutBlankPopupRequestHandler: Cef.RequestHandlerRef {

    public AboutBlankPopupRequestHandler(WebView web_view, AboutBlankPopupClient client) {
        base();
        priv_set<unowned WebView>("web_view", web_view);
        priv_set<unowned AboutBlankPopupClient>("client", client);
       
        /**
         * Called on the UI thread before browser navigation. Return true (1) to
         * cancel the navigation or false (0) to allow the navigation to proceed. The
         * |request| object cannot be modified in this callback.
         * cef_load_handler_t::OnLoadingStateChange will be called twice in all cases.
         * If the navigation is allowed cef_load_handler_t::OnLoadStart and
         * cef_load_handler_t::OnLoadEnd will be called. If the navigation is canceled
         * cef_load_handler_t::OnLoadError will be called with an |errorCode| value of
         * ERR_ABORTED.
         */
        /*int*/ vfunc_on_before_browse = (
            self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request, /*int*/ is_redirect
        ) => {
            bool user_gesture;
            switch (request.get_transition_type()) {
            case Cef.TransitionType.LINK:
            case Cef.TransitionType.EXPLICIT:
            case Cef.TransitionType.MANUAL_SUBFRAME:
            case Cef.TransitionType.FORM_SUBMIT:
                user_gesture = true;
                break;
            default:
                user_gesture = false;
                break;
            }
            var navigation_request = new NavigationRequest(
                browser, frame, request.get_url(), frame != null ? frame.get_name() : null,
                Cef.WindowOpenDisposition.UNKNOWN, request.get_transition_type(),
                request.get_resource_type(), user_gesture, true, (bool) is_redirect);
            unowned WebView _web_view = ((Cef.RequestHandlerRef) self).priv_get<unowned WebView>("web_view");
            _web_view.navigation_request(navigation_request);
            ((Cef.RequestHandlerRef) self).priv_get<unowned AboutBlankPopupClient>("client").navigation_request(
                navigation_request);
            return navigation_request.allowed ? 0 : 1;
        };

        /**
         * Called on the UI thread before OnBeforeBrowse in certain limited cases
         * where navigating a new or different browser might be desirable. This
         * includes user-initiated navigation that might open in a special way (e.g.
         * links clicked via middle-click or ctrl + left-click) and certain types of
         * cross-origin navigation initiated from the renderer process (e.g.
         * navigating the top-level frame to/from a file URL). The |browser| and
         * |frame| values represent the source of the navigation. The
         * |target_disposition| value indicates where the user intended to navigate
         * the browser based on standard Chromium behaviors (e.g. current tab, new
         * tab, etc). The |user_gesture| value will be true (1) if the browser
         * navigated via explicit user gesture (e.g. clicking a link) or false (0) if
         * it navigated automatically (e.g. via the DomContentLoaded event). Return
         * true (1) to cancel the navigation or false (0) to allow the navigation to
         * proceed in the source browser's top-level frame.
         */
        /*int*/ vfunc_on_open_urlfrom_tab = (
            self, /*Browser*/ browser, /*Frame*/ frame, /*String*/ target_url,
            /*WindowOpenDisposition*/ target_disposition, /*int*/ user_gesture
        ) => {
            if (frame.is_main() == 1) {
                warning("vfunc_on_open_urlfrom_tab: '%s' %s %s",
                Cef.get_string(target_url),
                target_disposition.to_string(),
                user_gesture.to_string());
            }
            return 0;
        };
    }
}

} // namespace CefGtk
