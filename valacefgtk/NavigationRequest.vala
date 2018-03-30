namespace CefGtk {

public class NavigationRequest {
    public Cef.Browser browser {get; private set;}
    public Cef.Frame frame {get; private set;}
    public string? target_url {get; private set;}
    public string? target_frame_name {get; private set;}
    public Cef.WindowOpenDisposition target_disposition {get; private set;}
    public Cef.TransitionType transition_type {get; private set;}
    public Cef.ResourceType resource_type {get; private set;}
    public bool user_gesture {get; private set;}
    public bool new_window {get; private set;}
    public bool is_redirect {get; private set;}
    public bool allowed {get; private set;}

    public NavigationRequest(
        Cef.Browser browser, Cef.Frame frame, string? target_url, string? target_frame_name,
        Cef.WindowOpenDisposition target_disposition, Cef.TransitionType transition_type,
        Cef.ResourceType resource_type, bool user_gesture, bool new_window, bool is_redirect
    ) {
        this.browser = browser;
        this.frame = frame;
        this.target_url = target_url;
        this.target_frame_name = target_frame_name;
        this.target_disposition = target_disposition;
        this.transition_type = transition_type;
        this.resource_type = resource_type;
        this.user_gesture = user_gesture;
        this.new_window = new_window;
        this.is_redirect = is_redirect;
        this.allowed = true;
    }

    public void allow() {
        allowed = true;
    }

    public void cancel() {
        allowed = false;
    }
} 

} // namespace CefGtk
