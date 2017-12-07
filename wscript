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

def find_python3(ctx, version=None):
    ctx.find_program('python3', var='PYTHON3')
    if version:
        versions = [int(s) for s in version.split('.')]
        ctx.start_msg("Checking for Python >= %s" % version)
        py_version = ctx.cmd_and_log(
            [ctx.env.PYTHON3[0], '--version'], output=waflib.Context.STDOUT, quiet=waflib.Context.BOTH)
        py_version = py_version.strip().split(' ')[1]
        py_versions = [int(s) for s in py_version.split('.')]
        if py_versions >= versions:
            ctx.end_msg(py_version, color='GREEN')
        else:
            ctx.end_msg(py_version, color='RED')
            if len(versions) == 1:
                ctx.fatal("Could not find Python >= %s" % version)
            else:
                del ctx.env.PYTHON3
                for i in reversed(range(versions[1], 8)):
                    try:
                        ctx.find_program('python3.%d' % i, var='PYTHON3')
                        break
                    except waflib.Errors.ConfigurationError:
                        pass
                else:
                    ctx.fatal("Could not find PythonXX >= %s" % version)
                ctx.start_msg("Checking for Python >= %s" % version)
                py_version = ctx.cmd_and_log(
                    [ctx.env.PYTHON3[0], '--version'], output=waflib.Context.STDOUT, quiet=waflib.Context.BOTH)
                py_version = py_version.strip().split(' ')[1]
                py_versions = [int(s) for s in py_version.split('.')]
                if py_versions >= versions:
                    ctx.end_msg(py_version, color='GREEN')
                else:
                    ctx.end_msg(py_version, color='RED')
                    ctx.fatal("Could not find Python >= %s" % version)


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
    find_python3(ctx, "3.6")


def build(ctx):
    cef_vala, valacef_api_vapi, valacef_api_h = [ctx.path.find_or_declare(i) for i in ('cef.vala', 'valacef_api.vapi', 'valacef_api.h')]
    ctx(
        rule='${PYTHON3} ../genvalacef.py .. .',
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

