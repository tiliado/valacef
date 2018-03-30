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

        /**
         * Called on the IO thread before a resource request is loaded. The |request|
         * object may be modified. Return RV_CONTINUE to continue the request
         * immediately. Return RV_CONTINUE_ASYNC and call cef_request_tCallback::
         * cont() at a later time to continue or cancel the request asynchronously.
         * Return RV_CANCEL to cancel the request immediately.
         * 
         */
        /*ReturnValue*/ vfunc_on_before_resource_load = (self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request, /*RequestCallback*/ callback) => {
            return Cef.ReturnValue.ONTINUE;
        };

        /**
         * Called on the IO thread before a resource is loaded. To allow the resource
         * to load normally return NULL. To specify a handler for the resource return
         * a cef_resource_handler_t object. The |request| object should not be
         * modified in this callback.
         */
        //*ResourceHandler*/ vfunc_get_resource_handler => (self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request);

        /**
         * Called on the IO thread when a resource load is redirected. The |request|
         * parameter will contain the old URL and other request-related information.
         * The |response| parameter will contain the response that resulted in the
         * redirect. The |new_url| parameter will contain the new URL and can be
         * changed if desired. The |request| object cannot be modified in this
         * callback.
         */
        /*void*/ vfunc_on_resource_redirect = (self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request, /*Response*/ response, /*String*/ new_url) => {
        };

        /**
         * Called on the IO thread when a resource response is received. To allow the
         * resource to load normally return false (0). To redirect or retry the
         * resource modify |request| (url, headers or post body) and return true (1).
         * The |response| object cannot be modified in this callback.
         */
        /*int*/ vfunc_on_resource_response = (self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request, /*Response*/ response) => {
            return 0;
        };

        /**
         * Called on the IO thread to optionally filter resource response content.
         * |request| and |response| represent the request and response respectively
         * and cannot be modified in this callback.
         */
        //*ResponseFilter*/ vfunc_get_resource_response_filter => (self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request, /*Response*/ response);

        /**
         * Called on the IO thread when a resource load has completed. |request| and
         * |response| represent the request and response respectively and cannot be
         * modified in this callback. |status| indicates the load completion status.
         * |received_content_length| is the number of response bytes actually read.
         */
        //*void*/ vfunc_on_resource_load_complete => (self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request, /*Response*/ response, /*UrlrequestStatus*/ status, /*int64*/ received_content_length);

        /**
         * Called on the IO thread when the browser needs credentials from the user.
         * |isProxy| indicates whether the host is a proxy server. |host| contains the
         * hostname and |port| contains the port number. |realm| is the realm of the
         * challenge and may be NULL. |scheme| is the authentication scheme used, such
         * as "basic" or "digest", and will be NULL if the source of the request is an
         * FTP server. Return true (1) to continue the request and call
         * cef_auth_callback_t::cont() either in this function or at a later time when
         * the authentication information is available. Return false (0) to cancel the
         * request immediately.
         */
        //*int*/ vfunc_get_auth_credentials => (self, /*Browser*/ browser, /*Frame*/ frame, /*int*/ isProxy, /*String*/ host, /*int*/ port, /*String*/ realm, /*String*/ scheme, /*AuthCallback*/ callback);

        /**
         * Called on the IO thread before sending a network request with a "Cookie"
         * request header. Return true (1) to allow cookies to be included in the
         * network request or false (0) to block cookies. The |request| object should
         * not be modified in this callback.
         */
        /*int*/ vfunc_can_get_cookies = (self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request) => {
            return 1;
        };

        /**
         * Called on the IO thread when receiving a network request with a "Set-
         * Cookie" response header value represented by |cookie|. Return true (1) to
         * allow the cookie to be stored or false (0) to block the cookie. The
         * |request| object should not be modified in this callback.
         */
        /*int*/ vfunc_can_set_cookie = (self, /*Browser*/ browser, /*Frame*/ frame, /*Request*/ request, /*Cookie*/ cookie) => {
            return 1;
        };

        /**
         * Called on the IO thread when JavaScript requests a specific storage quota
         * size via the webkitStorageInfo.requestQuota function. |origin_url| is the
         * origin of the page making the request. |new_size| is the requested quota
         * size in bytes. Return true (1) to continue the request and call
         * cef_request_tCallback::cont() either in this function or at a later time to
         * grant or deny the request. Return false (0) to cancel the request
         * immediately.
         */
        //*int*/ vfunc_on_quota_request => (self, /*Browser*/ browser, /*String*/ origin_url, /*int64*/ new_size, /*RequestCallback*/ callback);

        /**
         * Called on the UI thread to handle requests for URLs with an unknown
         * protocol component. Set |allow_os_execution| to true (1) to attempt
         * execution via the registered OS protocol handler, if any. SECURITY WARNING:
         * YOU SHOULD USE THIS METHOD TO ENFORCE RESTRICTIONS BASED ON SCHEME, HOST OR
         * OTHER URL ANALYSIS BEFORE ALLOWING OS EXECUTION.
         */
        //*void*/ vfunc_on_protocol_execution => (self, /*Browser*/ browser, /*String*/ url, /*int*/ allow_os_execution);

        /**
         * Called on the UI thread to handle requests for URLs with an invalid SSL
         * certificate. Return true (1) and call cef_request_tCallback::cont() either
         * in this function or at a later time to continue or cancel the request.
         * Return false (0) to cancel the request immediately. If
         * CefSettings.ignore_certificate_errors is set all invalid certificates will
         * be accepted without calling this function.
         */
        //*int*/ vfunc_on_certificate_error => (self, /*Browser*/ browser, /*Errorcode*/ cert_error, /*String*/ request_url, /*Sslinfo*/ ssl_info, /*RequestCallback*/ callback);

        /**
         * Called on the UI thread when a client certificate is being requested for
         * authentication. Return false (0) to use the default behavior and
         * automatically select the first certificate available. Return true (1) and
         * call cef_select_client_certificate_callback_t::Select either in this
         * function or at a later time to select a certificate. Do not call Select or
         * call it with NULL to continue without using any certificate. |isProxy|
         * indicates whether the host is an HTTPS proxy or the origin server. |host|
         * and |port| contains the hostname and port of the SSL server. |certificates|
         * is the list of certificates to choose from; this list has already been
         * pruned by Chromium so that it only contains certificates from issuers that
         * the server trusts.
         */
        //*int*/ vfunc_on_select_client_certificate => (self, /*Browser*/ browser, /*int*/ isProxy, /*String*/ host, /*int*/ port, /*X509certificate[]*/ certificates, /*SelectClientCertificateCallback*/ callback);

        /**
         * Called on the browser process UI thread when a plugin has crashed.
         * |plugin_path| is the path of the plugin that crashed.
         */
        //*void*/ vfunc_on_plugin_crashed => (self, /*Browser*/ browser, /*String*/ plugin_path);

        /**
         * Called on the browser process UI thread when the render view associated
         * with |browser| is ready to receive/handle IPC messages in the render
         * process.
         */
        //*void*/ vfunc_on_render_view_ready => (self, /*Browser*/ browser);

        /**
         * Called on the browser process UI thread when the render process terminates
         * unexpectedly. |status| indicates how the process terminated.
         */
        //*void*/ vfunc_on_render_process_terminated => (self, /*Browser*/ browser, /*TerminationStatus*/ status);
    }
}

} // namespace CefGtk
