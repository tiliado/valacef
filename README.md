Vala-CEF 3.0
===========

**WIP [Vala](https://wiki.gnome.org/Projects/Vala) bindings for
[Chromium Embedded Framework](https://bitbucket.org/chromiumembedded/cef/)**

![Screenshot](cefium.png)

Tested Configuration
------------------

  * CEF 3.3239.1703
  * Chromium 63.0.3239.109
  * GTK+ 3.22.26

Components
---------

  * [valacefgen](./valacefgen): Generates Vala bindings for CEF C API from CEF C header files.
  * [valacef](./valacef): Combines generates Vala bindings and extra goodies into a shared library.
  * [valacefgtk](./valacefgtk): High-level GTK+ 3 based API inspired by WebKitGTK+.
  * [cefium](./cefium): A demo web browser based on valacef(gtk).

Dependencies
-----------

  * Python >= 3.6
  * Vala => 0.34.7
  * glib-2.0 >= 2.52.0
  * gtk+-3.0 >= 3.22.0
  * x11
  * CEF 3.3239.1703 (built with GTK+ 3)

Build Instructions
----------------

  * `./waf --help`
  * `./waf configure`
  * `make run`

Copyright
--------

  * Copyright 2017 Jiří Janoušek
  * License: [BSD-2-Clause](./LICENSE)
  
