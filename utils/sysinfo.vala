namespace SysInfo {

Gtk.Window window;

int main(string[] argv) {
    unowned string[] gtk_argv = null;
    Gtk.init(ref gtk_argv);
    window = new Gtk.Window();
    window.set_default_size(100, 100);
    window.title = "Hello.";
    window.add(new Gtk.Label("Hello."));
    window.show_all();
    Idle.add(() => {collect_info(); Gtk.main_quit(); return false;});
    Gtk.main();
    return 0;
}

void collect_info() {
    print_dpi();
    ln();
    print_properties(Gtk.Settings.get_default());
}

void ln () {
    stdout.puts("\n");
}

void print_properties(GLib.Object object) {
    unowned string name = object.get_type().name();
    stdout.printf("==== %s properties ====\n", name);
    unowned ObjectClass klass =  object.get_class();
    (unowned ParamSpec)[] properties = klass.list_properties();
    foreach (unowned ParamSpec prop in properties) {
        unowned Type type = prop.value_type;
        if (type == typeof(string)) {
            string? str_val = null;
            object.get(prop.name, out str_val);
            if (str_val == null) {
                stdout.printf("%s = null string\n", prop.name);
            } else {
                stdout.printf("%s = \"%s\"\n", prop.name, str_val);
            }
        } else if (type == typeof(int)) {
            int int_val = 0;
            object.get(prop.name, out int_val);
            stdout.printf("%s = %d\n", prop.name, int_val);
        } else if (type == typeof(uint)) {
            uint uint_val = 0;
            object.get(prop.name, out uint_val);
            stdout.printf("%s = %u\n", prop.name, uint_val);
        } else if (type == typeof(bool)) {
            bool bool_val = false;
            object.get(prop.name, out bool_val);
            stdout.printf("%s = %s\n", prop.name, bool_val ? "true" : "false");
        } else {
            stdout.printf("%s = unknown type %s\n", prop.name, type.name());
        }
    }
}

void print_dpi() {
    stdout.printf("==== DPI ====\n");
    double xft_dpi = 1.0 * Gtk.Settings.get_default().gtk_xft_dpi / 1024;
    stdout.printf("Gtk.Settings.gtk_xft_dpi    = %f\n", xft_dpi);
    stdout.printf("   calcd scaling factor     = %f\n", xft_dpi / 96);
    stdout.printf("Gtk.Widget.scale_factor     = %d\n", window.scale_factor);
    stdout.printf("Gdk.Window.scale_factor     = %d\n", window.get_window().get_scale_factor());
    unowned Gdk.Display display = Gdk.Display.get_default();
    int n_monitors = display.get_n_monitors();
    for (var i = 0; i < n_monitors; i++) {
        stdout.printf(
            "Gdk.Monitor[%d].scale_factor = %d\n",
            i, display.get_monitor(i).get_scale_factor());
    }
}

}
