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

push:
	git checkout master
	git push && git push --tags
	git checkout 3.3683.x
	git push && git push --tags
	git checkout master

merge:
	git checkout 3.3683.x
	git merge --ff-only master
	git checkout master
