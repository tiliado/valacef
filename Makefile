all: build/cef.vapi build/example.bin

build/cef.vapi build/cef.vala:
	python3 genvalacef.py

build/example.bin: example/example.vala example/cef_x11.vala build/cef.vapi build/cef.vala
	touch build/cef.h
	valac -d build --pkg posix --save-temps -v \
	--vapidir=vapi \
	--pkg gtk+-3.0 --pkg gdk-3.0 --pkg gdk-x11-3.0 \
	-X -I. \
	-X -Ibuild -X -I/app/include/cef -X -I/app/include/cef/include \
	-X -L/app/lib/cef -X -lcef -X /app/lib/cef/libcef_dll_wrapper \
	-o example.bin $^

run: all
	LD_LIBRARY_PATH=/app/lib/cef build/example.bin
	
clean:
	rm -rf build
