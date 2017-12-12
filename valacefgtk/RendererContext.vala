namespace CefGtk {

public delegate void InitRendererExtensionFunc(RendererContext ctx);

public class RendererContext : GLib.Object {
    public RenderProcessHandler handler {get; construct;}
    public RenderSideEventLoop event_loop {get; construct;}
    
    public RendererContext(RenderProcessHandler handler) {
        GLib.Object(handler: handler, event_loop: new RenderSideEventLoop());
    }
    
    public void init(Cef.ListValue? extra_info) {
        event_loop.start();
    }
    
    public void load_renderer_extension(string path) {
        assert(Module.supported());
        var module = Module.open(path, ModuleFlags.BIND_LAZY);
        if (module == null) {
            warning("Failed to load Renderer Extension '%s': %s", path, Module.error());
        } else {
            void* function;
            module.symbol("init_renderer_extension", out function);
            if (function == null) {
                warning("renderer Extension '%s' does not contain init_renderer_extension() function.", path);
            } else {
                InitRendererExtensionFunc init_renderer_extension = (InitRendererExtensionFunc) function;
                init_renderer_extension(this);
            }
        }
    }
    
    public bool message_received(Cef.Browser? browser, Cef.ProcessMessage? msg) {
        var args = msg.get_argument_list();
        var name = args.get_string(0);
        var parameter = args.get_string(1);
        if (name == "load_renderer_extension" && parameter != null) {
            event_loop.add_idle(() => {load_renderer_extension(parameter); return false;});
        } else {
            message("Message received: '%s' '%s'", name, parameter);
        }
        return true;
    }
}

} // namespace CefGtk
