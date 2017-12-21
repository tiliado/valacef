namespace CefGtk {

public delegate void InitRendererExtensionFunc(RendererContext ctx, Variant?[] parameters);

public class RendererContext : GLib.Object {
    public RenderProcessHandler handler {get; construct;}
    public RenderSideEventLoop event_loop {get; construct;}
    
    public RendererContext(RenderProcessHandler handler) {
        GLib.Object(handler: handler, event_loop: new RenderSideEventLoop());
    }
    
    public void init(Cef.ListValue? extra_info) {
        event_loop.start();
    }
    
    public void load_renderer_extension(string path, Variant?[] parameters) {
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
                init_renderer_extension(this, parameters);
            }
        }
    }
    
    public bool message_received(Cef.Browser? browser, Cef.ProcessMessage? msg) {
        var args = Utils.convert_list_to_variant(msg.get_argument_list());
        var name = msg.get_name();
        if (name == "load_renderer_extension") {
            var extension = args[0].get_string();
            event_loop.add_idle(() => {load_renderer_extension(extension, args); return false;});
        } else {
            message("Message received: '%s'", name);
        }
        return true;
    }
}

} // namespace CefGtk
