namespace Cef {

[CCode (cheader_filename = "cef_version.h")]
private extern int version_info(int entry);

[CCode (cname="VALACEF_VERSION_MAJOR")]
private extern const int VALACEF_VERSION_MAJOR;

[CCode (cname="VALACEF_VERSION_MINOR")]
private extern const int VALACEF_VERSION_MINOR;

public int get_cef_major() {
	return version_info(0);
}


public int get_cef_commit() {
	return version_info(1);
}


public int get_chrome_major() {
	return version_info(2);
}


public int get_chrome_minor() {
	return version_info(3);
}


public int get_chrome_build() {
	return version_info(4);
}


public int get_chrome_patch() {
	return version_info(5);
}


public int get_valacef_major() {
	return VALACEF_VERSION_MAJOR;
}


public int get_valacef_minor() {
	return VALACEF_VERSION_MINOR;
}


public string get_valacef_version() {
	return "%d.%d".printf(get_valacef_major(), get_valacef_minor());
}


public string get_cef_version() {
	return "%d.%d.%d".printf(get_cef_major(), get_chrome_build(), get_cef_commit());
}


public string get_chrome_version() {
	return "%d.%d.%d.%d".printf(get_chrome_major(), get_chrome_minor(), get_chrome_build(), get_chrome_patch());
}

}
