run:
	./waf build -v
	sh build/launch.sh build/Cefium

gdb:
	./waf build -v
	sh build/launch.sh gdb --args build/Cefium

config:
	./waf configure

rebuild:
	./waf distclean configure
	./waf build -v

clean:
	rm -rf build
