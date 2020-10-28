namespace CefGtk {

public class WebContext : GLib.Object {
    private static SList<WeakRef<WebContext>> all_contexts = null;
    public string? user_data_path {get; construct;}
    internal Cef.RequestContext request_context;
    internal Cef.RequestContextHandlerRef context_handler;
    internal Cef.CookieManager cookie_manager;

    public static void notify_render_process_created(Cef.ListValue extra_info) {
        foreach (unowned WeakRef<WebContext> weakref in all_contexts) {
            var ctx = weakref.get();
            if (ctx != null) {
                ctx.render_process_created(extra_info);
            }
        }
    }

    public WebContext(string? user_data_path) {
        GLib.Object(user_data_path: user_data_path);
        all_contexts.append(new WeakRef<WebContext>(this));
    }

    public signal void render_process_created(Cef.ListValue extra_info);

    construct {
        assert(CefGtk.is_initialized());
        Cef.assert_browser_ui_thread();
        Cef.RequestContextSettings request_settings = {sizeof(Cef.RequestContextSettings)};
        if (user_data_path != null) {
            Cef.set_string(&request_settings.cache_path, user_data_path);
        }
        request_settings.persist_session_cookies = 1;
        request_settings.persist_user_preferences = 1;
        request_settings.enable_net_security_expiration = 1;


        context_handler = new Handler();
        request_context = Cef.request_context_create_context(request_settings, context_handler);
        cookie_manager = request_context.get_cookie_manager(null);
        assert(cookie_manager != null);
        Timeout.add(200, () => {
            cookie_manager.flush_store(null);
            return true;
        });
    }

    private class Handler : Cef.RequestContextHandlerRef {
        public Handler() {
            base();

            /**
             * Called on the browser process UI thread immediately after the request
             * context has been initialized.
             */
            /*void vfunc_on_request_context_initialized(owned RequestContext? request_context);*/

            /**
             * Called on multiple browser process threads before a plugin instance is
             * loaded. |mime_type| is the mime type of the plugin that will be loaded.
             * |plugin_url| is the content URL that the plugin will load and may be NULL.
             * |is_main_frame| will be true (1) if the plugin is being loaded in the main
             * (top-level) frame, |top_origin_url| is the URL for the top-level frame that
             * contains the plugin when loading a specific plugin instance or NULL when
             * building the initial list of enabled plugins for 'navigator.plugins'
             * JavaScript state. |plugin_info| includes additional information about the
             * plugin that will be loaded. |plugin_policy| is the recommended policy.
             * Modify |plugin_policy| and return true (1) to change the policy. Return
             * false (0) to use the recommended policy. The default plugin policy can be
             * set at runtime using the `--plugin-policy=[allow|detect|block]` command-
             * line flag. Decisions to mark a plugin as disabled by setting
             * |plugin_policy| to PLUGIN_POLICY_DISABLED may be cached when
             * |top_origin_url| is NULL. To purge the plugin list cache and potentially
             * trigger new calls to this function call
             * cef_request_tContext::PurgePluginListCache.
             */
            /*int on_before_plugin_load(String* mime_type, String* plugin_url, int is_main_frame, String* top_origin_url, owned WebPluginInfo? plugin_info, PluginPolicy? plugin_policy);*/

        }
    }
}

}  // namespace CefGtk
