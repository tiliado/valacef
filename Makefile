all: build/cef.vapi build/example.bin

build/cef.vapi:
	python3 genvalacef.py

build/example.bin: example/example.vala build/cef.vapi
	valac -d build --pkg posix -o example.bin $^

clean:
	rm -rf build
