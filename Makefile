run:
	./waf build -v
	sh build/launch.sh build/example.bin

config:
	./waf configure

rebuild:
	./waf distclean configure
	./waf build -v

clean:
	rm -rf build
