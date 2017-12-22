namespace Cef.V8 {

public class SimpleAccessor : V8accessorRef {
	public SimpleAccessor() {
		base();
		/**
         * Handle retrieval the accessor value identified by |name|. |object| is the
         * receiver ('this' object) of the accessor. If retrieval succeeds set
         * |retval| to the return value. If retrieval fails set |exception| to the
         * exception that will be thrown. Return true (1) if accessor retrieval was
         * handled.
         */
        /*int*/ vfunc_get = (self, /*String*/ name, /*V8value*/ object, /*V8value*/ out retval,
        /*String*/ exception) => {
			message("SimpleV8accessor.set");
			return 0;
		};
		
        /**
         * Handle assignment of the accessor value identified by |name|. |object| is
         * the receiver ('this' object) of the accessor. |value| is the new value
         * being assigned to the accessor. If assignment fails set |exception| to the
         * exception that will be thrown. Return true (1) if accessor assignment was
         * handled.
         */
        /*int*/ vfunc_set = (self, /*String*/ name, /*V8value*/ object, /*V8value*/ value,
        /*String*/ exception) => {
			message("SimpleV8accessor.set");
			return 0;
		};
	}
}

} // namespace Cef.V8
