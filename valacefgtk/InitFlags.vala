namespace CefGtk {

public class InitFlags {
    public AutoPlayPolicy auto_play_policy {get; set; default = AutoPlayPolicy.DEFAULT;}

    public InitFlags() {}
}

public enum AutoPlayPolicy {
    /**
     * Use default policy.
     */
    DEFAULT,
    /**
     * Autoplay policy that requires a document user activation.
     */
    DOCUMENT_USER_ACTIVATION_REQUIRED,
    /**
     * Autoplay policy that does not require any user gesture.
     */
    NO_USER_GESTURE_REQUIRED,
    /**
     * Autoplay policy to require a user gesture in order to play.
     */
    USER_GESTURE_REQUIRED,
    /**
     * Autoplay policy to require a user gesture in order to play for cross origin iframes.
     */
    USER_GESTURE_REQUIRED_FOR_CROSS_ORIGIN;

    public string to_string() {
        switch (this) {
        case DOCUMENT_USER_ACTIVATION_REQUIRED:
            return "document-user-activation-required";
        case NO_USER_GESTURE_REQUIRED:
            return "no-user-gesture-required";
        case USER_GESTURE_REQUIRED:
            return "user-gesture-required";
        case USER_GESTURE_REQUIRED_FOR_CROSS_ORIGIN:
            return "user-gesture-required-for-cross-origin";
        default:
            return "";
        }
    }
}

} // namespace CefGtk
