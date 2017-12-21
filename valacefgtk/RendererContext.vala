namespace CefGtk {

public delegate void InitRendererExtensionFunc(RendererContext ctx, int browser, Variant?[] parameters);

public class RendererContext : GLib.Object {
    public RenderProcessHandler handler {get; construct;}
    public RenderSideEventLoop event_loop {get; construct;}
    private SList<RendererExtension> renderer_extensions = null;
    
    public RendererContext(RenderProcessHandler handler) {
        GLib.Object(handler: handler, event_loop: new RenderSideEventLoop(GLib.MainContext.@default()));
    }
    
    public void init(Cef.ListValue? extra_info) {
        event_loop.start();
    }
    
    public virtual signal void browser_created(Cef.Browser browser) {
        send_message(browser, MsgId.BROWSER_CREATED, {browser.get_identifier()});
    }
    
    public virtual signal void browser_destroyed(Cef.Browser browser) {
        send_message(browser, MsgId.BROWSER_DESTROYED, {browser.get_identifier()});
    }
    
    public void load_renderer_extension(Cef.Browser browser, string path, owned Variant?[] parameters) {
        assert(GLib.Module.supported());
        var module = GLib.Module.open(path, 0);
        if (module == null) {
            warning("Failed to load Renderer Extension '%s': %s", path, GLib.Module.error());
        } else {
            void* function;
            module.symbol("init_renderer_extension", out function);
            if (function == null) {
                warning("renderer Extension '%s' does not contain init_renderer_extension() function.", path);
            } else {
                var extension = new RendererExtension(
                    this, browser.get_identifier(), (owned) module, function, (owned) parameters);
                renderer_extensions.prepend(extension);
                event_loop.add_idle(extension.idle_callback);
            }
        }
    }
    
    public void send_message(Cef.Browser browser, string name, Variant?[] parameters) {
        var msg = Utils.create_process_message(name, parameters);
        browser.send_process_message(Cef.ProcessId.RENDERER, msg);
    }
    
    public bool message_received(Cef.Browser? browser, Cef.ProcessMessage? msg) {
        var args = Utils.convert_list_to_variant(msg.get_argument_list());
        var name = msg.get_name();
        if (name == MsgId.LOAD_RENDERER_EXTENSION) {
            var extension = args[0].get_string();
            load_renderer_extension(browser, extension, args);
        } else {
            message("Message received: '%s'", name);
        }
        return true;
    }
    
    private class RendererExtension {
        unowned RendererContext ctx;
        int browser;
        GLib.Module? module;
        void* init_function;
        Variant?[] parameters;
        
        public RendererExtension(RendererContext ctx, int browser, owned GLib.Module? module,
        void* init_function, owned Variant?[] parameters) {
            this.ctx = ctx;
            this.browser = browser;
            this.module = (owned) module;
            this.init_function = init_function;
            this.parameters = (owned) parameters;
        }
        
        public bool idle_callback() {
            InitRendererExtensionFunc init_renderer_extension = (InitRendererExtensionFunc) init_function;
            init_renderer_extension(ctx, browser, parameters);
            parameters = null;
            return false;
        }
    }
}

} // namespace CefGtk
