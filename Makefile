run:
	./waf build -v
	LD_LIBRARY_PATH=/app/lib/cef:build build/example.bin

config:
	./waf configure

rebuild:
	./waf distclean configure
	./waf build -v

clean:
	rm -rf build
