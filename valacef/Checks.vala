namespace Cef {

public void assert_renderer_thread(string context=GLib.Log.METHOD) {
	if (Cef.currently_on(Cef.ThreadId.RENDERER) == 0) {
		error("%s: Not on Renderer thread.", context);
	}
}

public void assert_browser_ui_thread(string context=GLib.Log.METHOD) {
	if (Cef.currently_on(Cef.ThreadId.UI) == 0) {
		error("%s: Not on Browser UI thread.", context);
	}
}

public void assert_browser_io_thread(string context=GLib.Log.METHOD) {
	if (Cef.currently_on(Cef.ThreadId.IO) == 0) {
		error("%s: Not on Browser IO thread.", context);
	}
}

public bool on_renderer_thread(string context=GLib.Log.METHOD) {
	return Cef.currently_on(Cef.ThreadId.RENDERER) == 1;
}

public bool on_browser_ui_thread(string context=GLib.Log.METHOD) {
	return Cef.currently_on(Cef.ThreadId.UI) == 1;
}

public bool on_browser_io_thread(string context=GLib.Log.METHOD) {
	return Cef.currently_on(Cef.ThreadId.IO) == 1;
}

public int get_current_thread_id() {
    Cef.ThreadId[] ids = {
        Cef.ThreadId.UI,
        Cef.ThreadId.DB,
        Cef.ThreadId.FILE,
        Cef.ThreadId.FILE_USER_BLOCKING,
        Cef.ThreadId.PROCESS_LAUNCHER,
        Cef.ThreadId.CACHE,
        Cef.ThreadId.IO,
        Cef.ThreadId.RENDERER
    };
    foreach (var id in ids) {
        if (Cef.currently_on(id) == 1) {
            return id;
        }
    }
    return -1;
}

public string? get_current_thread_name() {
    var id = get_current_thread_id();
    return id == -1 ? null : ((Cef.ThreadId) id).to_string();
}

} // namespace Cef
