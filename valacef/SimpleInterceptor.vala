namespace Cef.V8 {

public class SimpleInterceptor : V8interceptorRef {
	public SimpleInterceptor(){
		base();
        /**
         * Handle retrieval of the interceptor value identified by |name|. |object| is
         * the receiver ('this' object) of the interceptor. If retrieval succeeds, set
         * |retval| to the return value. If the requested value does not exist, don't
         * set either |retval| or |exception|. If retrieval fails, set |exception| to
         * the exception that will be thrown. If the property has an associated
         * accessor, it will be called only if you don't set |retval|. Return true (1)
         * if interceptor retrieval was handled, false (0) otherwise.
         */
        /*int*/ vfunc_get_byname = (self, /*String*/ name, /*V8value*/ object, /*V8value*/ out retval,
        /*String*/ exception) => {
			message("SimpleV8interceptor.get_byname");
			return 0;
		};

        /**
         * Handle retrieval of the interceptor value identified by |index|. |object|
         * is the receiver ('this' object) of the interceptor. If retrieval succeeds,
         * set |retval| to the return value. If the requested value does not exist,
         * don't set either |retval| or |exception|. If retrieval fails, set
         * |exception| to the exception that will be thrown. Return true (1) if
         * interceptor retrieval was handled, false (0) otherwise.
         */
        /*int*/ vfunc_get_byindex = (self, /*int*/ index, /*V8value*/ object, /*V8value*/ out retval,
         /*String*/ exception) => {
			message("SimpleV8interceptor.get_byindex");
			return 0;
		};

        /**
         * Handle assignment of the interceptor value identified by |name|. |object|
         * is the receiver ('this' object) of the interceptor. |value| is the new
         * value being assigned to the interceptor. If assignment fails, set
         * |exception| to the exception that will be thrown. This setter will always
         * be called, even when the property has an associated accessor. Return true
         * (1) if interceptor assignment was handled, false (0) otherwise.
         */
        /*int*/ vfunc_set_byname = (self, /*String*/ name, /*V8value*/ object, /*V8value*/ value,
         /*String*/ exception) => {
			message("SimpleV8interceptor.set_byname");
            ((V8interceptorRef) self).priv_set(Cef.get_string(name), value);
			return 1;
		};

        /**
         * Handle assignment of the interceptor value identified by |index|. |object|
         * is the receiver ('this' object) of the interceptor. |value| is the new
         * value being assigned to the interceptor. If assignment fails, set
         * |exception| to the exception that will be thrown. Return true (1) if
         * interceptor assignment was handled, false (0) otherwise.
         */
        /*int*/ vfunc_set_byindex = (self, /*int*/ index, /*V8value*/ object, /*V8value*/ value,
        /*String*/ exception) => {
			message("SimpleV8interceptor.set_byindex");
			return 0;
		};
    }
}

} // namespace Cef.V8
