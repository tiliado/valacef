namespace CefGtk {

public class WeakRef<T> {
    private GLib.Object object = null;
    
    public WeakRef(GLib.Object object) {
        set(object);
    }
    
    public T? get() {
        lock (this.object) {
            return (T) this.object;
        }
    }
    
    public void set(GLib.Object? object) {
        assert(object == null || object is T);
        lock (this.object) {
            if (this.object != null) {
                this.object.weak_unref(on_finalized);
            }
            this.object = object;
            this.object.weak_ref(on_finalized);
        }
    }
    
    private void on_finalized(GLib.Object object) {
        lock (this.object) {
            assert(this.object == object);
            this.object.weak_unref(on_finalized);
            this.object = null;
        }
    }
}

} // namespace CefGtk
