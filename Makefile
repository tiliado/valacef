run:
	./waf build -v
	LD_LIBRARY_PATH=/app/lib/cef build/example.bin

config:
	./waf configure

clean:
	rm -rf build
