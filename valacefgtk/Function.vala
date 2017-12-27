namespace CefGtk { 

public class Function {
    public delegate void HandlerFunc(string? name, Cef.V8value? object, Cef.V8value?[] arguments,
    out Cef.V8value? retval, out string? exception);
    
    public static Cef.V8value create(string name, owned HandlerFunc handler) {
        Cef.assert_renderer_thread();
        Cef.String _name = {};
        Cef.set_string(&_name, name);
        var _handler = new Handler(new Function((owned) handler));
        return Cef.v8value_create_function(&_name, _handler);
    }
    
    private HandlerFunc handler;
    
    private Function(owned HandlerFunc handler) {
        Cef.assert_renderer_thread();
        this.handler = (owned) handler;
    }
    
    public void run(string? name, Cef.V8value? object, Cef.V8value?[] arguments, out Cef.V8value? retval,
    out string? exception) {
        handler(name, object, arguments, out retval, out exception);
    }
    
    private class Handler : Cef.V8handlerRef {
        public Handler(Function function) {
            base();
            priv_set("function", function);
            /**
             * Handle execution of the function identified by |name|. |object| is the
             * receiver ('this' object) of the function. |arguments| is the list of
             * arguments passed to the function. If execution succeeds set |retval| to the
             * function return value. If execution fails set |exception| to the exception
             * that will be thrown. Return true (1) if execution was handled.
             */
            /*int*/ vfunc_execute = (self, /*String*/ name, /*V8value*/ object, /*V8value?[]*/ arguments,
            out /*V8value*/ retval, /*String*/ exception) => {
                Cef.assert_renderer_thread();
                string? _exception = null;
                assert ((int)((void*) object) != 0x2);
                ((Cef.V8handlerRef) self).priv_get<Function>("function").run(
                    Cef.get_string(name), object, arguments, out retval, out _exception);
                if (_exception != null) {
                    Cef.set_string(exception, _exception);
                }
                return 1;
            };
        }
    }
}

} // namespace Cef
