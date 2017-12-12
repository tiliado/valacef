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
    
    public bool message_received(Cef.Browser? browser, Cef.ProcessMessage? msg) {
        var args = msg.get_argument_list();
        var name = args.get_string(0);
        var parameter = args.get_string(1);
        message("Message received: '%s' '%s'", name, parameter);
        return true;
    }
}

} // namespace CefGtk
