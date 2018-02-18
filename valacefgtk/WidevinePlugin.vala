namespace CefGtk {

public class WidevinePlugin: GLib.Object {
    public bool registration_complete {get; private set; default = false;}
    public bool available {get; private set; default = false;}
    public Cef.CdmRegistrationError registration_status {
        get; private set; default = Cef.CdmRegistrationError.NOT_SUPPORTED;}
    public string? registration_error {get; private set; default = null;}
    
    public WidevinePlugin() {
    }
    
    public void register(string path) {
        assert(!CefGtk.is_initialized());
        debug("Widevine path: %s", path);
        Cef.String cef_path = {};
		Cef.set_string(&cef_path, path);
        Cef.register_widevine_cdm(&cef_path, new RegisterCallback(this));
    }
    
    public virtual signal void registration_finished(Cef.CdmRegistrationError status, string? error) {
        this.registration_status = status;
        this.registration_error = error;
        this.registration_complete = true;
        this.available = status == Cef.CdmRegistrationError.NONE;
        if (available) {
            message("WidevinePlugin is available: %d %s", (int) status, error);
        } else {
            warning("WidevinePlugin not available: %d %s", (int) status, error);
        }
    }
    
    public class RegisterCallback: Cef.RegisterCdmCallbackRef {
        public RegisterCallback(WidevinePlugin plugin) {
            base();
            priv_set("plugin", plugin);
            vfunc_on_cdm_registration_complete = (self, /*CdmRegistrationError*/ result, /*String*/ error_message) => {
                Cef.assert_browser_ui_thread();
                ((Cef.RegisterCdmCallbackRef) self).priv_get<WidevinePlugin>("plugin").registration_finished(
                    result, Cef.get_string(error_message));
            };
        }
    }
}

} // namespace CefGtk
