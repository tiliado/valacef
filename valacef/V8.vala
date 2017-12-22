namespace Cef.V8 {

public V8value create_string(string? value) {
    String _value = {};
    if (value != null) {
        Cef.set_string(&_value, value);
    }
    return v8value_create_string(&_value);
}

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

public V8value? get_function(V8value object, string key) {
    var value = get_value(object, key);
    return (value != null && value.is_function() != 0) ? value : null;
}

public V8value? get_object(V8value object, string key) {
    var value = get_value(object, key);
    return (value != null && value.is_object() != 0) ? value : null;
}

public V8value? get_value(V8value object, string key) {
    Cef.String _key = {};
    Cef.set_string(&_key, key);
    return object.get_value_bykey(&_key);
}

public string? string_or_null(V8value? value) {
    if (value == null) {
        return null;
    } else if (value.is_string() > 0) {
        return value.get_string_value();
    }
    return null;
    // TODO: why this fails to return a valid string.
    // return value == null ? null : (value.is_string() != 0 ? value.get_string_value() : null);
}

public string format_exception(Cef.V8exception exception) {
    var buf = new StringBuilder("");
    buf.append_printf("%s:%d: %s\n%s\n",
        exception.get_script_resource_name(), exception.get_line_number(), exception.get_message(),
        exception.get_source_line());
    var start = exception.get_start_column();
    var end = exception.get_end_column();
    for (var i = 0; i <= end; i++) {
        buf.append_c(i < start ? ' ' : '^');
    }
    return buf.str;
}

public V8value? parse_json(V8context context, string json, out string? error) {
    error = null;
    var object = Cef.V8.get_object(context.get_global(), "JSON");
    if (object == null) {
        error = "Cannot find window.JSON object in the given V8 context.";
        return null;
    }
    object.ref();
    var func = Cef.V8.get_function(object, "parse");
    if (func == null) {
        error = "Cannot find window.JSON.parse function in the given V8 context.";
        return null;
    }
    var _json = create_string(json == "" ? "{}" : json);
    _json.ref();
    var result = func.execute_function(object, {_json});
    if (result == null) {
        error = format_exception(func.get_exception());
        return null;
    } else {
        return result;
    }
}

} // namespace Cef.V8
