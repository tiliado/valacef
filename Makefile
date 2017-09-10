all: build/cef.vapi build/example.bin

build/cef.vapi build/cef.vala:
	python3 genvalacef.py

build/example.bin: example/example.vala build/cef.vapi build/cef.vala
	touch build/cef.h
	valac -d build --pkg posix --save-temps -v \
	-X -I. \
	-X -Ibuild -X -I/app/include/cef -X -I/app/include/cef/include \
	-X -L/app/lib/cef -X -lcef -X /app/lib/cef/libcef_dll_wrapper \
	-o example.bin $^

clean:
	rm -rf build
