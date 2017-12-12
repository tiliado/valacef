namespace CefGtk {

public class RendererContext : GLib.Object {
    public RenderProcessHandler handler {get; construct;}
    public RenderSideEventLoop event_loop {get; construct;}
    
    public RendererContext(RenderProcessHandler handler) {
        GLib.Object(handler: handler, event_loop: new RenderSideEventLoop());
    }
    
    public void init(Cef.ListValue? extra_info) {
        event_loop.start();
    }
}

} // namespace CefGtk
