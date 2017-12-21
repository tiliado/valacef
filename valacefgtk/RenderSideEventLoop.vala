namespace CefGtk {

public class RenderSideEventLoop : GLib.Object {
    public MainLoop loop;
    public MainContext context;
    public Thread<void*> thread;
    
    public RenderSideEventLoop(MainContext? main_context=null) {
        context = main_context ?? new MainContext();
    }
    
    public RenderSideEventLoop start() {
        assert(thread == null);
        thread = new Thread<void*>("RenderSideEventLoop", run);
        return this;
    }
    
    /**
     * Attach an idle callback to this event loop.
     * 
     * Similar to {@link GLib.Idle.add} but uses this event loop instead of the global
     * {@link GLib.MainContext}.
     * 
     * @param function    The idle callback function.
     * @param priority    The priority of the callback.
     * @return Id of the corresponding event source.
     */
    public uint add_idle(owned SourceFunc function, int priority=GLib.Priority.DEFAULT_IDLE) {
        var source = new IdleSource();
        source.set_priority(priority);
        source.set_callback((owned) function);
        return source.attach(context);
    }
    
    /**
     * Attach a timeout callback to this event loop.
     * 
     * Similar to {@link GLib.Timeout.add} but uses this event loop instead of the global
     * {@link GLib.MainContext}.
     * 
     * @param interval_ms    The number of miliseconds to wait before the callback is called.
     * @param function       The callback function.
     * @param priority       The priority of the callback.
     * @return Id of the corresponding event source.
     */
    public uint add_timeout(uint interval_ms, owned SourceFunc function, int priority=GLib.Priority.DEFAULT) {
        var source = new TimeoutSource(interval_ms);
        source.set_priority(priority);
        source.set_callback((owned) function);
        return source.attach(context ?? MainContext.ref_thread_default());
    }
    
    private void* run() {
        context.push_thread_default();
        loop = new MainLoop(context);
        loop.run();
        loop = null;
        context.pop_thread_default();
        return null;
    }
    
    public void stop() {
        loop.quit();
        thread.join();
        thread = null;
    }
}

} // namespace CefGtk
