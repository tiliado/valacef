namespace Cefium {


} // namespace Cefium

public void init_renderer_extension(CefGtk.RendererContext ctx, int browser, Variant?[] parameters) {
    message("Extension for browser(%d)'s renderer.", browser);
    for (var i = 0; i < parameters.length; i++) {
        message("init_renderer_extension[%d]: %s", i, parameters[i] == null ? "null" : parameters[i].print(false));
    }
}
