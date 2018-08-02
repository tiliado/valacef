Building Chromium Embedded Framework for ValaCEF
===========================================

Paths
-----

  * /media/fenryxo/exthdd7/cef/build/ -- the build directory
  * /media/fenryxo/exthdd7/cef/build/ -- the download directory
  * /home/fenryxo/dev/projects/cef/cef -- the CEF source directory

Install dependencies
------------------

On Debian Stretch:

    apt install \
      curl build-essential flex g++ git-svn libcairo2-dev libglib2.0-dev \
      libcups2-dev libgtkglext1-dev git-core libglu1-mesa-dev libnspr4-dev \
      libnss3-dev libgnome-keyring-dev libasound2-dev gperf bison libpci-dev \
      libkrb5-dev libgtk-3-dev libxss-dev python libpulse-dev ca-certificates

Maybe also something from this:

    apt install \
      elfutils fakeroot libav-tools libbrlapi-dev libbz2-dev libcap-dev \
      libcurl4-gnutls-dev libdrm-dev libelf-dev libexif-dev libffi-dev \
      libgconf2-dev libgl1-mesa-dev libgtk2.0-dev libpam0g-dev libpulse-dev \
      libsctp-dev libspeechd-dev libsqlite3-dev libssl-dev libudev-dev \
      libwww-perl libxslt1-dev libxt-dev libxtst-dev mesa-common-dev \
      patch perl pkg-config python python-crypto python-dev python-psutil \
      python-numpy python-opencv python-openssl python-yaml ruby subversion \
      ttf-dejavu-core fonts-indic fonts-thai-tlwg wdiff wget zip

Download automate-git.py script
----------------------------

    mkdir -p /media/fenryxo/exthdd7/cef/build
    cd /media/fenryxo/exthdd7/cef/build
    wget https://bitbucket.org/chromiumembedded/cef/raw/master/tools/automate/automate-git.py

Set up environment
----------------

If you live in the USA, consult either your lawyer or therapist before enabling proprietary codecs.
Yes, there might be some patents. Software patents don't apply in the Czech Republic and we also
have excellent beer, btw.

    export GN_DEFINES='use_gtk3=true is_official_build=true use_allocator=none symbol_level=1 ffmpeg_branding=Chrome proprietary_codecs=true'
    export CFLAGS="-Wno-error"
    export CXXFLAGS="-Wno-error"
    export CEF_ARCHIVE_FORMAT=tar.bz2

Download & build CEF
------------------

### Full download

    cd /media/fenryxo/exthdd7/cef/build/
    time python automate-git.py --download-dir=download \
      --url=/home/fenryxo/dev/projects/cef/cef \
      --branch=3440 --checkout=3440-valacef \
      --force-clean --force-clean-deps --force-config \
      --x64-build --build-target=cefsimple --no-build --no-distrib

### Update

    cd /media/fenryxo/exthdd7/cef/build/
    time python automate-git.py --download-dir=download \
      --url=/home/fenryxo/dev/projects/cef/cef \
      --branch=3440 --checkout=origin/3440-valacef \
      --force-clean --force-config \
      --x64-build --build-target=cefsimple --no-build --no-distrib

### Build

    time python automate-git.py --download-dir=download \
      --url=/home/fenryxo/dev/projects/cef/cef \
      --branch=3440  --checkout=origin/3440-valacef \
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
