namespace CefGtk {

public class BrowserProcess : Cef.AppRef {
    public BrowserProcess() {
        base();
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
            message("get_browser_process_handler");
            return null;
        };
    }
}

} // namespace CefGtk
