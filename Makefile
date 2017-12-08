run:
	./waf build -v
	sh build/launch.sh build/example.bin

gdb:
	./waf build -v
	sh build/launch.sh gdb --args build/example.bin

config:
	./waf configure

rebuild:
	./waf distclean configure
	./waf build -v

clean:
	rm -rf build
