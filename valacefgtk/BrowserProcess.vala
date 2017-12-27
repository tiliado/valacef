namespace CefGtk {

public class BrowserProcess : Cef.AppRef {
    public BrowserProcess(FlashPlugin? flash_plugin) {
        base();
        priv_set("bph", new BrowserProcessHandler());
        priv_set("flash_plugin", flash_plugin);
        
        /**
         * Provides an opportunity to register custom schemes. Do not keep a reference
         * to the |registrar| object. This function is called on the main thread for
         * each process and the registered schemes should be the same across all
         * processes.
         */
        vfunc_on_register_custom_schemes = (self, scheme_registrar) => {};

        /**
         * Return the handler for resource bundle events. If
         * CefSettings.pack_loading_disabled is true (1) a handler must be returned.
         * If no handler is returned resources will be loaded from pack files. This
         * function is called by the browser and render processes on multiple threads.
         */
        vfunc_get_resource_bundle_handler = (self) => null;

        /**
         * Return the handler for functionality specific to the browser process. This
         * function is called on multiple threads in the browser process.
         */
        vfunc_get_browser_process_handler = (self) => {
            return ((BrowserProcess) self).priv_get<BrowserProcessHandler>("bph");
        };
        
        /**
         * Provides an opportunity to view and/or modify command-line arguments before
         * processing by CEF and Chromium. The |process_type| value will be NULL for
         * the browser process. Do not keep a reference to the cef_command_line_t
         * object passed to this function. The CefSettings.command_line_args_disabled
         * value can be used to start with an NULL command-line object. Any values
         * specified in CefSettings that equate to command-line arguments will be set
         * before this function is called. Be cautious when using this function to
         * modify command-line arguments for non-browser processes as this may result
         * in undefined behavior including crashes.
         */
        /*void*/ vfunc_on_before_command_line_processing = (self, /*String*/ process_type, /*CommandLine*/ command_line
        ) => {
            assert(!CefGtk.is_initialized());
            var flash = ((BrowserProcess) self).priv_get<FlashPlugin?>("flash_plugin");
            if (flash != null && flash.available) {
                Cef.String name = {};
                Cef.String value = {};
                Cef.set_string(&name, "ppapi-flash-path");
                Cef.set_string(&value, flash.plugin_path);
                command_line.append_switch_with_value(&name, &value);
                Cef.set_string(&name, "ppapi-flash-version");
                Cef.set_string(&value, flash.version);
                command_line.append_switch_with_value(&name, &value);
                Cef.set_string(&name, "plugin-policy");
                Cef.set_string(&value, "allow");
                command_line.append_switch_with_value(&name, &value);
            }
        };
    }
}

} // namespace CefGtk
