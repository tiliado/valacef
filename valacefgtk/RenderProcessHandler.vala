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
    }
}

} // namespace CefGtk
