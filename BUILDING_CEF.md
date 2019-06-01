Building Chromium Embedded Framework for ValaCEF
===========================================

Paths
-----

  * /media/fenryxo/exthdd7/cef/build/ -- the build directory
  * /media/fenryxo/exthdd7/cef/build/ -- the download directory
  * /home/fenryxo/dev/projects/cef/cef -- the CEF source directory

Install dependencies
------------------

On Ubuntu 18.04 LTS:

    apt install \
      curl build-essential flex g++ git-svn libcairo2-dev libglib2.0-dev \
      libcups2-dev libgtkglext1-dev git-core libglu1-mesa-dev libnspr4-dev \
      libnss3-dev libgnome-keyring-dev libasound2-dev gperf bison libpci-dev \
      libkrb5-dev libgtk-3-dev libxss-dev python libpulse-dev ca-certificates \
      default-jre

Use LXC container (here in Fedora 29):

    sudo lxc-create -n cef-bionic -t /usr/share/lxc/templates/lxc-download  -- -d ubuntu -r bionic -a amd64
    sudo lxc-start -n cef-bionic
    sudo lxc-attach -n cef-bionic
        apt update && apt full-upgrade
        apt install ...
        mkdir -p /media/fenryxo/exthdd7/cef
        poweroff
    sudo nano /var/lib/lxc/cef-bionic/config
        lxc.mount.entry = /media/fenryxo/exthdd7/cef media/fenryxo/exthdd7/cef none bind 0 0


Download automate-git.py script
----------------------------

    mkdir -p /media/fenryxo/exthdd7/cef/build
    cd /media/fenryxo/exthdd7/cef/build
    wget https://bitbucket.org/chromiumembedded/cef/raw/master/tools/automate/automate-git.py

Set up environment
----------------

    sudo lxc-start -n cef-bionic
    sudo lxc-attach -n cef-bionic
    apt update; apt full-upgrade
    su ubuntu
    cd /media/fenryxo/exthdd7/cef/build
    export GN_DEFINES='is_official_build=true use_allocator=none symbol_level=1 ffmpeg_branding=Chrome proprietary_codecs=true'
    export CFLAGS="-Wno-error"
    export CXXFLAGS="-Wno-error"
    export CEF_ARCHIVE_FORMAT=tar.bz2

Download & build CEF
------------------

### Full download

    cd /media/fenryxo/exthdd7/cef/build/
    time python automate-git.py --download-dir=download \
      --url=/home/fenryxo/dev/projects/cef/cef \
      --branch=3729 --checkout=3729-valacef \
      --force-clean --force-clean-deps --force-config \
      --x64-build --build-target=cefsimple --no-build --no-distrib

### Update

    cd /media/fenryxo/exthdd7/cef/build/
    time python automate-git.py --download-dir=download \
      --url=/home/fenryxo/dev/projects/cef/cef \
      --branch=3729 --checkout=origin/3729-valacef \
      --force-clean --force-config \
      --x64-build --build-target=cefsimple --no-build --no-distrib

### Build

    time python automate-git.py --download-dir=download \
      --url=/home/fenryxo/dev/projects/cef/cef \
      --branch=3729  --checkout=origin/3729-valacef \
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
