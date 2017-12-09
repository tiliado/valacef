namespace CefGtk {

public class BrowserProcessHandler : Cef.BrowserProcessHandlerRef {
    private static IdleSource? cef_idle_work = null;
    
    public BrowserProcessHandler() {
        base();
        
        if (cef_idle_work == null) {
            cef_idle_work = new IdleSource();
            cef_idle_work.set_callback(do_cef_work_now);
        }
        
       /**
         * Called on the browser process UI thread immediately after the CEF context
         * has been initialized.
         */
        /*void*/ vfunc_on_context_initialized = (self) => {
            message("vfunc_on_context_initialized");
        };

        /**
         * Called before a child process is launched. Will be called on the browser
         * process UI thread when launching a render process and on the browser
         * process IO thread when launching a GPU or plugin process. Provides an
         * opportunity to modify the child process command line. Do not keep a
         * reference to |command_line| outside of this function.
         */
        /*void*/ vfunc_on_before_child_process_launch = (self, /*CommandLine*/ command_line) => {
            message("vfunc_on_before_child_process_launch");
        };

        /**
         * Called on the browser process IO thread after the main thread has been
         * created for a new render process. Provides an opportunity to specify extra
         * information that will be passed to
         * cef_render_process_handler_t::on_render_thread_created() in the render
         * process. Do not keep a reference to |extra_info| outside of this function.
         */
        /*void*/ vfunc_on_render_process_thread_created = (self, /*ListValue*/ extra_info) => {
            message("vfunc_on_render_process_thread_created");
        };

        /**
         * Return the handler for printing on Linux. If a print handler is not
         * provided then printing will not be supported on the Linux platform.
         */
        /*PrintHandler*/ vfunc_get_print_handler = (self) => {
            message("vfunc_get_print_handler");
            return null;
        };

        /**
         * Called from any thread when work has been scheduled for the browser process
         * main (UI) thread. This callback is used in combination with CefSettings.
         * external_message_pump and cef_do_message_loop_work() in cases where the CEF
         * message loop must be integrated into an existing application message loop
         * (see additional comments and warnings on CefDoMessageLoopWork). This
         * callback should schedule a cef_do_message_loop_work() call to happen on the
         * main (UI) thread. |delay_ms| is the requested delay in milliseconds. If
         * |delay_ms| is <= 0 then the call should happen reasonably soon. If
         * |delay_ms| is > 0 then the call should be scheduled to happen after the
         * specified delay and any currently pending scheduled call should be
         * cancelled.
         */
        /*void*/ vfunc_on_schedule_message_pump_work = (self, /*int64*/ delay_ms) => {
            if (delay_ms <= 0) {
                if (cef_idle_work.get_context() == null) {
                    cef_idle_work.attach(null);
                }
            }
            /* We use a 50 ms timer for CEF work at init.vala */
        };
    }
    
    private static bool do_cef_work_now() {
        Cef.do_message_loop_work();
        return false;
    }
}

} // namespace CefGtk
