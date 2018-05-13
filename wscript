APPNAME = 'valacef'
VERSION = '3.3396.0'
MIN_VALA = "0.34.7"
MIN_GLIB = "2.52.0"
MIN_GTK = "3.22.0"

top = '.'
out = 'build'

import os
import waflib

REVISION_SNAPSHOT = "snapshot"


def get_git_version():
    import os
    import subprocess
    if os.path.isdir(".git"):
        output = subprocess.check_output(["git", "describe", "--tags", "--long"])
        return output.decode("utf-8").strip().split("-")
    return VERSION, "0", REVISION_SNAPSHOT

def add_version_info(ctx):
    bare_version, n_commits, revision_id = get_git_version()
    if revision_id != REVISION_SNAPSHOT:
        revision_id = "{}-{}".format(n_commits, revision_id)
    versions = list(int(i) for i in bare_version.split("."))
    versions[2] += int(n_commits)
    version = "{}.{}.{}".format(*versions)
    ctx.env.VERSION = version
    ctx.env.VERSIONS = versions
    ctx.env.REVISION_ID = revision_id

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
    pkgconfig(ctx, 'gmodule-2.0', 'GMODULE', MIN_GLIB)
    pkgconfig(ctx, 'gio-unix-2.0', 'UNIXGIO', MIN_GLIB)
    pkgconfig(ctx, 'gtk+-3.0', 'GTK', MIN_GTK)
    pkgconfig(ctx, 'gdk-x11-3.0', 'GDKX11', MIN_GTK)
    pkgconfig(ctx, 'x11', 'X11', "0")
    find_python3(ctx, "3.6")

    CEF_PREFIX = os.environ.get("CEF_PREFIX")
    if CEF_PREFIX:
        find_cef(ctx, [CEF_PREFIX + '/lib/cef'], [CEF_PREFIX + '/include/cef/include'])
    else:
        find_cef(ctx)
    
    ctx.env.append_unique("VALAFLAGS", "-v")
    ctx.env.append_unique('CFLAGS', ['-w', '-Wno-incompatible-pointer-types'])
    ctx.env.append_unique("LINKFLAGS", ["-Wl,--no-undefined", "-Wl,--as-needed"])
    ctx.env.append_unique('CFLAGS', '-O2')
    ctx.env.append_unique('CFLAGS', '-g3')
        
    ctx.env.VALACEF_LIBDIR = "%s/%s" % (ctx.env.LIBDIR, APPNAME)
    ctx.define("VALACEF_LIBDIR", ctx.env.VALACEF_LIBDIR)
    ctx.define("CEFIUM_LIBDIR", ctx.env.VALACEF_LIBDIR)
    
    add_version_info(ctx)


def build(ctx):
    vapi_dirs = ["vapi", out]
    env_vapi_dir = os.environ.get("VAPIDIR")
    if env_vapi_dir:
        vapi_dirs.extend(os.path.relpath(path) for path in env_vapi_dir.split(":"))
    include_dirs = [".", ctx.env.CEF_INCLUDE_DIR, os.path.dirname(ctx.env.CEF_INCLUDE_DIR), out]
    cef_vala, valacef_api_vapi, valacef_api_h, valacef_api_c = [ctx.path.find_or_declare(i) for i in (
        'cef.vala', 'valacef_api.vapi', 'valacef_api.h', 'valacef_api.c')]
    ctx.define('VALACEF_VERSION_MAJOR', ctx.env.VERSIONS[0])
    ctx.define('VALACEF_VERSION_MINOR', ctx.env.VERSIONS[1])
    ctx.define('VALACEF_VERSION_MICRO', ctx.env.VERSIONS[2])
    ctx(
        rule='${PYTHON3} ../genvalacef.py ${CEF_INCLUDE_DIR} .. .',
        source=[ctx.path.find_node('genvalacef.py')] + ctx.path.ant_glob('valacefgen/*.py'),
        target=[cef_vala, valacef_api_vapi, valacef_api_h, valacef_api_c]
    )
    
    ctx.shlib(
        source = [
            cef_vala, valacef_api_c,
            'valacef/version.vala',
            'valacef/constants.vala',
            'valacef/Checks.vala',
            'valacef/V8.vala',
            'valacef/SimpleInterceptor.vala',
            'valacef/SimpleAccessor.vala',
        ],
        target = 'valacef',
        packages = "valacef_api",
        defines = ['G_LOG_DOMAIN="Cef"', 'CEF_LIB_DIR="%s"' % ctx.env.CEF_LIB_DIR],
        vapi_dirs = vapi_dirs,
        includes = include_dirs,
        lib = ['cef'],
        libpath = [ctx.env.CEF_LIB_DIR],
        rpath = [ctx.env.CEF_LIB_DIR],
        cflags = ['-O2', ctx.env.CEF_LIB_WRAPPER], 
        #vala_target_glib = TARGET_GLIB,
        #install_path = ctx.env.NUVOLA_LIBDIR,
    )
    
    ctx.shlib(
        source = [
            'valacefgtk/init.vala',
            'valacefgtk/x11.vala',
            'valacefgtk/WeakRef.vala',
            'valacefgtk/WebView.vala',
            'valacefgtk/WebContext.vala',
            'valacefgtk/DownloadManager.vala',
            'valacefgtk/BrowserProcess.vala',
            'valacefgtk/AboutBlankPopupClient.vala',
            'valacefgtk/Client.vala',
            'valacefgtk/BrowserProcessHandler.vala',
            'valacefgtk/FocusHandler.vala',
            'valacefgtk/DisplayHandler.vala',
            'valacefgtk/LoadHandler.vala',
            'valacefgtk/LifeSpanHandler.vala',
            'valacefgtk/DownloadHandler.vala',
            'valacefgtk/KeyboardHandler.vala',
            'valacefgtk/JsdialogHandler.vala',
            'valacefgtk/UIEvents.vala',
            'valacefgtk/WidevinePlugin.vala',
            'valacefgtk/FlashPlugin.vala',
            'valacefgtk/RendererContext.vala',
            'valacefgtk/RenderProcess.vala',
            'valacefgtk/RenderProcessHandler.vala',
            'valacefgtk/RequestHandler.vala',
            'valacefgtk/AboutBlankPopupRequestHandler.vala',
            'valacefgtk/RenderSideEventLoop.vala',
            'valacefgtk/Utils.vala',
            'valacefgtk/MsgId.vala',
            'valacefgtk/Task.vala',
            'valacefgtk/Function.vala',
            'valacefgtk/Proxy.vala',
            'valacefgtk/NavigationRequest.vala',
        ],
        target = 'valacefgtk',
        packages = "valacef valacef_api gtk+-3.0 gdk-x11-3.0 x11 gmodule-2.0",
        uselib = "GTK GDKX11 X11 GMODULE",
        defines = ['G_LOG_DOMAIN="CefGtk"'],
        vapi_dirs = vapi_dirs,
        includes = include_dirs,
        use = ['valacef'],
        lib = ['cef', 'm'],
        libpath = [ctx.env.CEF_LIB_DIR],
        rpath = [ctx.env.CEF_LIB_DIR],
        cflags = ['-O2'], 
        #vala_target_glib = TARGET_GLIB,
        #install_path = ctx.env.NUVOLA_LIBDIR,
    )
    
    ctx.program(
        source = ['cefsubprocess/Subprocess.vala'],
        target = 'ValacefSubprocess',
        packages = "gtk+-3.0 gdk-x11-3.0 x11",
        uselib = "GTK GDKX11 X11",
        use = ['valacef', 'valacefgtk'],
        defines = ['G_LOG_DOMAIN="CefSub"'],
        vapi_dirs = vapi_dirs,
        includes = include_dirs,
        lib = ['cef'],
        libpath = [ctx.env.CEF_LIB_DIR],
        rpath = [ctx.env.CEF_LIB_DIR],
        cflags = ['-O2'], 
        #vala_target_glib = TARGET_GLIB,
        install_path = ctx.env.VALACEF_LIBDIR,
    )
    
    ctx.program(
        source = [
            'cefium/Cefium.vala',
            'cefium/Application.vala',
            'cefium/BrowserWindow.vala',
            'cefium/URLBar.vala',
            ],
        target = 'Cefium',
        use = ['valacef', 'valacefgtk'],
        packages = "gtk+-3.0 gdk-x11-3.0 x11",
        uselib = "GTK GDKX11 X11",
        defines = ['G_LOG_DOMAIN="Cefium"'],
        vapi_dirs = vapi_dirs,
        includes = include_dirs,
        lib = ['cef'],
        libpath = [ctx.env.CEF_LIB_DIR],
        rpath = [ctx.env.CEF_LIB_DIR],
        cflags = ['-O2'], 
        #vala_target_glib = TARGET_GLIB,
        #install_path = ctx.env.NUVOLA_LIBDIR,
    )
    
    ctx.shlib(
        source = [
            'cefium/CefiumRendererExtension.vala',
        ],
        target = 'cefiumrendererextension',
        use = ['valacef', 'valacefgtk'],
        packages = "gtk+-3.0 gdk-x11-3.0 x11 gmodule-2.0",
        uselib = "GTK GDKX11 X11 GMODULE",
        defines = ['G_LOG_DOMAIN="Cefium"'],
        vapi_dirs = vapi_dirs,
        includes = include_dirs,
        lib = ['cef'],
        libpath = [ctx.env.CEF_LIB_DIR],
        rpath = [ctx.env.CEF_LIB_DIR],
        cflags = ['-O2'], 
        #vala_target_glib = TARGET_GLIB,
        install_path = ctx.env.VALACEF_LIBDIR,
    )
    
    ctx(features = 'subst',
        source='launch.sh.in',
        target='launch.sh',
        CEF_LIB_DIR=ctx.env.CEF_LIB_DIR,
        OUT=out
    )
    
    ctx(features = 'subst',
        source='valacef/valacef.pc.in',
        target='valacef.pc',
        install_path='${LIBDIR}/pkgconfig',
        VERSION=ctx.env.VERSION,
        PREFIX=ctx.env.PREFIX,
        INCLUDEDIR = ctx.env.INCLUDEDIR,
        LIBDIR = ctx.env.LIBDIR,
        APPNAME=APPNAME,
        LIBNAME='valacef',
        CEFLIBDIR=ctx.env.CEF_LIB_DIR,
        INCLUDE_CEF_DIRS="-I%s -I%s" % (ctx.env.CEF_INCLUDE_DIR, os.path.dirname(ctx.env.CEF_INCLUDE_DIR)),
    )
    
    ctx(features = 'subst',
        source='valacefgtk/valacefgtk.pc.in',
        target='valacefgtk.pc',
        install_path='${LIBDIR}/pkgconfig',
        VERSION=ctx.env.VERSION,
        PREFIX=ctx.env.PREFIX,
        INCLUDEDIR = ctx.env.INCLUDEDIR,
        LIBDIR = ctx.env.LIBDIR,
        APPNAME=APPNAME,
        LIBNAME='valacefgtk',
        CEFLIBDIR=ctx.env.CEF_LIB_DIR,
        INCLUDE_CEF_DIRS="-I%s -I%s" % (ctx.env.CEF_INCLUDE_DIR, os.path.dirname(ctx.env.CEF_INCLUDE_DIR)),
    )
    
    ctx.install_files('${PREFIX}/share/vala/vapi', ['valacef_api.vapi'])
    ctx.install_files('${PREFIX}/include/valacef-1.0', ['valacef_api.h'])

