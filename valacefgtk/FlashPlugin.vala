namespace CefGtk {

public class FlashPlugin: GLib.Object {
    public const string FILENAME = "libpepflashplayer.so";
    public string? plugin_directory {get; private set; default = null;}
    public string? plugin_path {get; private set; default = null;}
    public string? registration_error {get; private set; default = null;}
    public bool available {get; private set; default = false;}
    public string version {get; private set; default = "";}
    
    public FlashPlugin() {        
    }
    
    public bool register(string plugin_directory) {
        var path = "%s/%s".printf(plugin_directory, FILENAME);
        if (FileUtils.test(path, FileTest.IS_REGULAR)) {
            this.plugin_path = path;
            path = "%s/%s.version".printf(plugin_directory, FILENAME);
            if (FileUtils.test(path, FileTest.IS_REGULAR)) {
                string? version;
                try {
                    FileUtils.get_contents(path, out version);
                } catch (GLib.FileError e) {
                    this.plugin_directory = null;
                    this.plugin_path = null;
                    this.registration_error = "Failed to read '%s': %s".printf(path, e.message);
                    this.available = false;
                    return false;
                }
                this.version = (version ?? "").strip();
                this.plugin_directory = plugin_directory;
                this.registration_error = null;
                this.available = true;
                return true;
            }
        } 
        this.plugin_directory = null;
        this.plugin_path = null;
        this.registration_error = "File '%s' does not exist.".printf(path);
        this.available = false;
        return false;
    }
}

} // namespace CefGtk
