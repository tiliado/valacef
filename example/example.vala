

public class MyApp: Cef.AppRef
{
	public MyApp() {
		base();
	}
}

int main(string[] argv) {
	var test = new MyApp();
	test.ref();
	test.unref();
	Cef.String cef_path = {};
	Cef.get_path(Cef.PathKey.DIR_MODULE, ref cef_path);
	warning("result: %s", Cef.get_string(ref cef_path));
	
	Cef.set_string(ref cef_path, "/app/lib/cef");
	Cef.override_path(Cef.PathKey.DIR_MODULE, ref cef_path);
	Cef.override_path(Cef.PathKey.DIR_EXE, ref cef_path);
	
	Cef.get_path(Cef.PathKey.DIR_MODULE, ref cef_path);
	warning("result: %s", Cef.get_string(ref cef_path));
	return 0;
}
