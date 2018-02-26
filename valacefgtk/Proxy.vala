namespace CefGtk {

public enum ProxyType {
    SYSTEM,
    NONE,
    HTTP,
    SOCKS;
}

[Compact]
public class ProxySettings {
    public ProxyType type;
    public string? server;
    public uint port;

    public ProxySettings(ProxyType proxy_type, string? proxy_server, uint proxy_port) {
        this.type = proxy_type;
        this.server = proxy_server;
        this.port = proxy_port;
    }
}

} // namespace CefGtk
