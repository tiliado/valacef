namespace CefGtk {

public class RenderProcess : Cef.AppRef {
    public RenderProcess() {
        base();
        priv_set("handler", new RenderProcessHandler());
        /**
         * Return the handler for functionality specific to the render process. This
         * function is called on the render process main thread.
         */
        /*RenderProcessHandler*/ vfunc_get_render_process_handler = (self) => {
            Cef.assert_renderer_thread();
            return ((Cef.AppRef) self).priv_get<RenderProcessHandler>("handler");
        };
    }
}

} // namespace CefGtk
