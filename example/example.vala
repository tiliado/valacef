

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
	return 0;
}
