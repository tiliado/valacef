namespace Cefium {


} // namespace Cefium

public void init_renderer_extension(CefGtk.RendererContext ctx, Variant?[] parameters) {
    for (var i = 0; i < parameters.length; i++) {
        message("init_renderer_extension[%d]: %s", i, parameters[i] == null ? "null" : parameters[i].print(false));
    }
}
