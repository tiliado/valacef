APPNAME = 'valacef'
VERSION = '3.0'
MIN_VALA = "0.34.7"
MIN_GLIB = "2.52.0"
MIN_GTK = "3.22.0"
VERSION_MAJOR, VERSION_MINOR = [int(s) for s in VERSION.split('.')]
top = '.'
out = 'build'

import os
import waflib

def find_cef(ctx, lib_dirs=None, incude_dirs=None):
    ctx.start_msg("Checking for 'libcef.so' dir")
    lib_dirs = lib_dirs or ('./cef/lib', '/app/lib/cef', '/usr/local/lib/cef', '/usr/lib/cef')
    for cef_lib_dir in lib_dirs:
        if os.path.isfile(os.path.join(cef_lib_dir, 'libcef.so')):
           ctx.env.CEF_LIB_DIR =  os.path.abspath(cef_lib_dir)
           ctx.end_msg(ctx.env.CEF_LIB_DIR)
           break
    else:
        ctx.end_msg(False, color='RED')
        ctx.fatal("Could not find 'libcef.so' in %s." % (lib_dirs,))
    
    ctx.start_msg("Checking for 'libcef_dll_wrapper'")
    libcef_dll_wrappers = 'libcef_dll_wrapper.a', 'libcef_dll_wrapper'
    for wrapper_name in libcef_dll_wrappers:
        wrapper_path = os.path.join(ctx.env.CEF_LIB_DIR, wrapper_name)
        if os.path.isfile(wrapper_path):
           ctx.env.CEF_LIB_WRAPPER =  wrapper_path
           ctx.end_msg(ctx.env.CEF_LIB_WRAPPER)
           break
    else:
        ctx.end_msg(False, color='RED')
        ctx.fatal("Could not find %s in '%s'." % (libcef_dll_wrappers, ctx.env.CEF_LIB_DIR))
    
    ctx.start_msg("Checking for 'cef_version.h' dir")
    incude_dirs = incude_dirs or ('./cef/include', '/app/include/cef/include', '/usr/local/include/cef/include', '/usr/include/cef/include')
    for cef_include_dir in incude_dirs:
        if os.path.isfile(os.path.join(cef_include_dir, 'cef_version.h')):
           ctx.env.CEF_INCLUDE_DIR =  os.path.abspath(cef_include_dir)
           ctx.end_msg(ctx.env.CEF_INCLUDE_DIR)
           break
    else:
        ctx.end_msg(False, color='RED')
        ctx.fatal("Could not find 'cef_version.h' in %s." % (incude_dirs,))

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
    find_cef(ctx)


def build(ctx):
    include_dirs = [".", ctx.env.CEF_INCLUDE_DIR, os.path.dirname(ctx.env.CEF_INCLUDE_DIR), out]
    cef_vala, valacef_api_vapi, valacef_api_h, valacef_api_c = [ctx.path.find_or_declare(i) for i in (
        'cef.vala', 'valacef_api.vapi', 'valacef_api.h', 'valacef_api.c')]
    ctx.define('VALACEF_VERSION_MAJOR', VERSION_MAJOR)
    ctx.define('VALACEF_VERSION_MINOR', VERSION_MINOR)
    ctx(
        rule='${PYTHON3} ../genvalacef.py ${CEF_INCLUDE_DIR} .. .',
        source=[ctx.path.find_node('genvalacef.py')] + ctx.path.ant_glob('valacefgen/*.py'),
        target=[cef_vala, valacef_api_vapi, valacef_api_h, valacef_api_c]
    )
    
    ctx.shlib(
        source = [cef_vala, valacef_api_c, 'valacef/version.vala'],
        target = 'valacef',
        packages = "valacef_api",
        defines = ['G_LOG_DOMAIN="ValaCef"'],
        vapi_dirs = ["vapi", out],
        includes = include_dirs,
        lib = ['cef'],
        libpath = [ctx.env.CEF_LIB_DIR],
        cflags = ['-O2', ctx.env.CEF_LIB_WRAPPER], 
        #vala_target_glib = TARGET_GLIB,
        #install_path = ctx.env.NUVOLA_LIBDIR,
    )
    
    ctx.program(
        source = ['example/example.vala', 'example/cef_x11.vala'],
        target = 'example.bin',
        use = ['valacef'],
        packages = "gtk+-3.0 gdk-x11-3.0 x11",
        uselib = "GTK GDKX11 X11",
        defines = ['G_LOG_DOMAIN="CefGtk"', 'CEF_LIB_DIR="%s"' % ctx.env.CEF_LIB_DIR],
        vapi_dirs = ["vapi"],
        includes = include_dirs,
        lib = ['cef'],
        libpath = [ctx.env.CEF_LIB_DIR],
        cflags = ['-O2'], 
        #vala_target_glib = TARGET_GLIB,
        #install_path = ctx.env.NUVOLA_LIBDIR,
    )
    
    ctx(features = 'subst',
		source='launch.sh.in',
		target='launch.sh',
		CEF_LIB_DIR=ctx.env.CEF_LIB_DIR,
        OUT=out
	)

