all: build/cef.vapi build/example.bin

build/cef.vapi build/cef.vala:
	python3 genvalacef.py

build/example.bin: example/example.vala build/cef.vapi build/cef.vala
	valac -d build --pkg posix --save-temps \
	-X -Ibuild -X -I/app/include/cef -X -I/app/include/cef/include \
	-o example.bin $^

clean:
	rm -rf build
