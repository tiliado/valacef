namespace CefGtk {

public class RenderProcessHandler: Cef.RenderProcessHandlerRef {
    public RenderProcessHandler() {
        base();
        /**
         * Called after the render process main thread has been created. |extra_info|
         * is a read-only value originating from
         * cef_browser_process_handler_t::on_render_process_thread_created(). Do not
         * keep a reference to |extra_info| outside of this function.
         */
        /*void*/ vfunc_on_render_thread_created = (self, /*ListValue*/ extra_info) => {
            var _this = ((RenderProcessHandler) self);
            var ctx = new RendererContext(_this);
            ctx.init(extra_info);
            _this.priv_set("context", ctx);
        };
        
        /**
         * Called when a new message is received from a different process. Return true
         * (1) if the message was handled or false (0) otherwise. Do not keep a
         * reference to or attempt to access the message outside of this callback.
         */
        /*int*/ vfunc_on_process_message_received = (self, /*Browser*/ browser, /*ProcessId*/ source_process,
         /*ProcessMessage*/ message) => {
            return (int) get_ctx(self).message_received(browser, message);
        };
        
        /**
         * Called after a browser has been created. When browsing cross-origin a new
         * browser will be created before the old browser with the same identifier is
         * destroyed.
         */
        /*void*/ vfunc_on_browser_created = (self, /*Browser*/ browser) => {
            get_ctx(self).browser_created(browser);
        };

        /**
         * Called before a browser is destroyed.
         */
        /*void*/ vfunc_on_browser_destroyed = (self, /*Browser*/ browser) => {
            get_ctx(self).browser_destroyed(browser);
        };
        
         /**
         * Called immediately after the V8 context for a frame has been created. To
         * retrieve the JavaScript 'window' object use the
         * cef_v8context_t::get_global() function. V8 handles can only be accessed
         * from the thread on which they are created. A task runner for posting tasks
         * on the associated thread can be retrieved via the
         * cef_v8context_t::get_task_runner() function.
         */
        /*void*/ vfunc_on_context_created = (self, /*Browser*/ browser, /*Frame*/ frame, /*V8context*/ context) => {
            get_ctx(self).js_context_created(browser, frame, context);
        };

        /**
         * Called immediately before the V8 context for a frame is released. No
         * references to the context should be kept after this function is called.
         */
        /*void*/ vfunc_on_context_released = (self, /*Browser*/ browser, /*Frame*/ frame, /*V8context*/ context) => {
            get_ctx(self).js_context_released(browser, frame, context);
        };
    }
    
    private static RendererContext get_ctx(Cef.RenderProcessHandler self) {
        return ((RenderProcessHandler) self).priv_get<RendererContext>("context");
    }
}

} // namespace CefGtk
