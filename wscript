APPNAME = 'valacef'
VERSION = '1.0'
MIN_VALA = "0.34.7"
MIN_GLIB = "2.52.0"
MIN_GTK = "3.22.0"

top = '.'
out = 'build'

import waflib
def vala_def(ctx, vala_definition):
    """Appends a Vala definition"""
    ctx.env.append_unique("VALA_DEFINES", vala_definition)

def pkgconfig(ctx, pkg, uselib, version, mandatory=True, store=None, valadef=None, define=None):
    """Wrapper for ctx.check_cfg."""
    result = True
    try:
        res = ctx.check_cfg(package=pkg, uselib_store=uselib, atleast_version=version, mandatory=True, args = '--cflags --libs')
        if valadef:
            vala_def(ctx, valadef)
        if define:
            for key, value in define.iteritems():
                ctx.define(key, value)
    except waflib.Errors.ConfigurationError as e:
        result = False
        if mandatory:
            raise e
    finally:
        if store is not None:
            ctx.env[store] = result
    return res

def options(ctx):
    ctx.load('compiler_c vala')


def configure(ctx):
    ctx.load('compiler_c vala')
    ctx.check_vala(min_version=tuple(int(i) for i in MIN_VALA.split(".")))
    pkgconfig(ctx, 'glib-2.0', 'GLIB', MIN_GLIB)
    pkgconfig(ctx, 'gio-2.0', 'GIO', MIN_GLIB)
    pkgconfig(ctx, 'gio-unix-2.0', 'UNIXGIO', MIN_GLIB)
    pkgconfig(ctx, 'gtk+-3.0', 'GTK', MIN_GTK)
    pkgconfig(ctx, 'gdk-x11-3.0', 'GDKX11', MIN_GTK)
    pkgconfig(ctx, 'x11', 'X11', "0")



def build(ctx):
    cef_vala, valacef_api_vapi, valacef_api_h = [ctx.path.find_or_declare(i) for i in ('cef.vala', 'valacef_api.vapi', 'valacef_api.h')]
    ctx(
        rule='python3 ../genvalacef.py .. .',
        source=[ctx.path.find_node('genvalacef.py')] + ctx.path.ant_glob('valacefgen/*.py'),
        target=[cef_vala, valacef_api_vapi, valacef_api_h]
    )
    
    ctx.shlib(
        source = [cef_vala, 'valacef/hello.vala'],
        target = 'valacef',
        packages = "valacef_api",
        defines = ['G_LOG_DOMAIN="ValaCef"'],
        vapi_dirs = ["vapi", out],
        includes = ['.', '/app/include/cef', '/app/include/cef/include', out],
        lib = ['cef'],
        libpath = ['/app/lib/cef'],
        cflags = ['-O2', '/app/lib/cef/libcef_dll_wrapper'], 
        #vala_target_glib = TARGET_GLIB,
        #install_path = ctx.env.NUVOLA_LIBDIR,
    )
    
    ctx.program(
        source = ['example/example.vala', 'example/cef_x11.vala'],
        target = 'example.bin',
        use = ['valacef'],
        packages = "gtk+-3.0 gdk-x11-3.0 x11",
        uselib = "GTK GDKX11 X11",
        defines = ['G_LOG_DOMAIN="CefGtk"'],
        vapi_dirs = ["vapi"],
        includes = ['.', '/app/include/cef', '/app/include/cef/include', out],
        lib = ['cef'],
        libpath = ['/app/lib/cef'],
        cflags = ['-O2'], 
        #vala_target_glib = TARGET_GLIB,
        #install_path = ctx.env.NUVOLA_LIBDIR,
    )

