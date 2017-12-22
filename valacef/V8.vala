namespace Cef.V8 {

public bool set_value(V8value object, string key, V8value? value) {
    Cef.String _key = {};
    Cef.set_string(&_key, key);
    V8value _value = value != null ? value : v8value_create_null();
    _value.ref();
    return (bool) object.set_value_bykey(&_key, _value, V8Propertyattribute.NONE);
}

public bool set_string(V8value object, string key, string? value) {
    if (value == null) {
        return set_value(object, key, null);
    } else {
        String _value = {};
        Cef.set_string(&_value, value);
        return set_value(object, key, v8value_create_string(&_value));
    }
}

public bool set_null(V8value object, string key) {
    return set_value(object, key, null);
}

public bool set_undefined(V8value object, string key) {
    return set_value(object, key, v8value_create_undefined());
}

public bool set_bool(V8value object, string key, bool value) {
    return set_value(object, key, v8value_create_bool((int) value));
}

public bool set_int(V8value object, string key, int value) {
    return set_value(object, key, v8value_create_int(value));
}

public bool set_uint(V8value object, string key, uint value) {
    return set_value(object, key, v8value_create_uint(value));
}

public bool set_double(V8value object, string key, double value) {
    return set_value(object, key, v8value_create_double( value));
}

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
        /*int*/ vfunc_get = (self, /*String*/ name, /*V8value*/ object, /*V8value*/ retval, /*String*/ exception) => {
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
        /*int*/ vfunc_set = (self, /*String*/ name, /*V8value*/ object, /*V8value*/ value, /*String*/ exception) => {
			message("SimpleV8accessor.set");
			return 0;
		};
	}
}

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
        /*int*/ vfunc_get_byname = (self, /*String*/ name, /*V8value*/ object, /*V8value*/ retval,
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
        /*int*/ vfunc_get_byindex = (self, /*int*/ index, /*V8value*/ object, /*V8value*/ retval,
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
