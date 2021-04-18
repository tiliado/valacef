Building Chromium Embedded Framework for ValaCEF
===========================================

You need [patched CEF 90.4430.x](https://github.com/tiliado/cef/tree/4430-valacef).

Paths
-----

  * $HOME/cef/build/ -- the build directory
  * $HOME/cef/build/ -- the download directory
  * $HOME/dev/projects/cef/cef -- the source directory
    of [patched CEF 90.4430.x](https://github.com/tiliado/cef/tree/4430-valacef)

Install dependencies
------------------

Use Podman container (here in Fedora 33)

    podman build --pull -t focal-cef:latest -f focal-cef.Dockerfile
    podman run -it --rm --security-opt label=disable -w /build \
      -v $HOME/cef/build:/build \
      -v $HOME/dev/projects/cef/cef:/build/dev/projects/cef/cef \
      focal-cef


Download automate-git.py script
----------------------------

    mkdir -p $HOME/cef/build
    cd $HOME/cef/build
    wget https://bitbucket.org/chromiumembedded/cef/raw/master/tools/automate/automate-git.py

Set up environment
----------------

    sudo lxc-start -n cef-bionic
    sudo lxc-attach -n cef-bionic
    apt update; apt full-upgrade
    su ubuntu
    cd $HOME/cef/build
    export GN_DEFINES='is_official_build=true use_allocator=none symbol_level=1 ffmpeg_branding=Chrome proprietary_codecs=true'
    export CFLAGS="-Wno-error"
    export CXXFLAGS="-Wno-error"
    export CEF_ARCHIVE_FORMAT=tar.bz2

Download & build CEF
------------------

### Full download

    cd $HOME/cef/build/
    time python automate-git.py --download-dir=download \
      --url=/home/fenryxo/dev/projects/cef/cef \
      --branch=4430 --checkout=4430-valacef \
      --force-clean --force-clean-deps --force-config \
      --x64-build --build-target=cefsimple --no-build --no-distrib

### Update

    cd $HOME/cef/build/
    time python automate-git.py --download-dir=download \
      --url=$HOME/dev/projects/cef/cef \
      --branch=4430 --checkout=origin/4430-valacef \
      --force-clean --force-config \
      --x64-build --build-target=cefsimple --no-build --no-distrib

### Build

    time python automate-git.py --download-dir=download \
      --url=$HOME/dev/projects/cef/cef \
      --branch=4430 --checkout=origin/4430-valacef \
      --x64-build --build-target=cefsimple --no-update --force-build \
      --no-debug-build

Install CEF to be found by ValaCEF
------------------------------

In the directory of an extracted minimal CEF distribution:

    mkdir -p build
    cd build
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release ..
    make
    su # or sudo su
    mkdir -p /usr/local/include/cef
    cp -r include /usr/local/include/cef
    mkdir -p /usr/local/lib/cef
    cp -r Release/* /usr/local/lib/cef
    cp build/libcef_dll_wrapper/libcef_dll_wrapper.a /usr/local/lib/cef/libcef_dll_wrapper.a
    cp -r Resources/* /usr/local/lib/cef

If you use a non-standard prefix (i.e. different than `/usr`, `/usr/local`, `/app`), use `CEF_PREFIX=/myprefix`
to build ValaCEF.

Issues
------

### curl: (35) error:140770FC:SSL routines:SSL23_GET_SERVER_HELLO:unknown protocol

This happens behind a HTTP proxy.

  * Use a VPN connection tunnelled through the proxy
  * unset http_proxy; unset https_proxy
  * nano /etc/resolv.conf

Build cefclient
---------------

* apt install libgtk2.0-dev libgtkglext1-dev cmake
* mkdir build && cd build
* cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug ..
* make -j4 cefclient cefsimple
