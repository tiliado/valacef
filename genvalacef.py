import os

from valacefgen.cparser import Parser, Naming
from valacefgen.types import Repository, Function
from valacefgen.utils import TypeInfo

header_files = [
    ('./overrides/cef_primitives.h', 'capi/cef_base_capi.h'),
    ('./overrides/cef_base.h', 'capi/cef_base_capi.h'),
    ('./overrides/cef_string.h', 'capi/cef_base_capi.h'),
    'internal/cef_types_linux.h',
    'internal/cef_types.h',
    'capi/cef_app_capi.h',
    'capi/cef_base_capi.h',
    'internal/cef_time.h',
    'capi/cef_command_line_capi.h',
    'capi/cef_browser_process_handler_capi.h',
    'capi/cef_render_process_handler_capi.h',
    'capi/cef_resource_bundle_handler_capi.h',
    'capi/cef_resource_handler_capi.h',
    'capi/cef_scheme_capi.h',
    'capi/cef_request_capi.h',
    'capi/cef_browser_capi.h',
    'capi/cef_path_util_capi.h',
    'capi/cef_client_capi.h',
    'capi/cef_dialog_handler_capi.h',
    'capi/cef_keyboard_handler_capi.h',
    'capi/cef_process_message_capi.h',
    'capi/cef_life_span_handler_capi.h',
    'capi/cef_load_handler_capi.h',
    'capi/cef_drag_handler_capi.h',
    'capi/cef_focus_handler_capi.h',
    'capi/cef_context_menu_handler_capi.h',
    'capi/cef_render_handler_capi.h',
    'capi/cef_jsdialog_handler_capi.h',
    'capi/cef_request_handler_capi.h',
    'capi/cef_download_handler_capi.h',
    'capi/cef_find_handler_capi.h',
    'capi/cef_geolocation_handler_capi.h',
    'capi/cef_display_handler_capi.h',
    'capi/cef_frame_capi.h',
    'capi/cef_menu_model_capi.h',
    'capi/cef_menu_model_delegate_capi.h',
    'capi/cef_download_item_capi.h',
    'capi/cef_drag_data_capi.h',
    'capi/cef_image_capi.h',
    'capi/cef_string_visitor_capi.h',
    'capi/cef_dom_capi.h',
    'capi/cef_v8_capi.h',
    'capi/cef_stream_capi.h',
    'capi/cef_values_capi.h',
    'capi/cef_accessibility_handler_capi.h',
    'capi/cef_response_capi.h',
    'capi/cef_task_capi.h',
    'capi/cef_response_filter_capi.h',
    'capi/cef_ssl_info_capi.h',
    'capi/cef_auth_callback_capi.h',
    'capi/cef_x509_certificate_capi.h',
    'capi/cef_request_context_capi.h',
    'capi/cef_request_context_handler_capi.h',
    'capi/cef_cookie_capi.h',
    'capi/cef_web_plugin_capi.h',
    'capi/cef_callback_capi.h',
    'capi/cef_print_handler_capi.h',
    'capi/cef_print_settings_capi.h',
    'capi/cef_navigation_entry_capi.h',
    'capi/cef_ssl_status_capi.h',
]

ignore = {
    'XEvent',
    'XDisplay',
    'cef_get_xdisplay',
}

base_structs = {
    "cef_base_scoped_t",
}

base_classes = {
    "cef_base_ref_counted_t",
}


class Overrides:
    def param__cef_string_utf8_to_utf16__src(self, info: TypeInfo):
        info.c_type = 'string'

    def param__cef_string_utf8_to_utf16__output(self, info: TypeInfo):
        info.ref = True

    def param__cef_string_utf16_to_utf8_output(self, info: TypeInfo):
        info.ref = True

parser = Parser(Naming('Cef'), Repository('Cef', Overrides()), ignore, base_structs, base_classes)

for entry in header_files:
    if isinstance(entry, str):
        c_include_path = entry
        path = os.path.join("/app/include/cef/include", entry)
    else:
        path, c_include_path = entry

    parser.parse_header(path, c_include_path)

repo = parser.repo
ref_func = Function('cef_base_ref_counted_ref', 'ref', "valacef.h")
unref_func = Function('cef_base_ref_counted_unref', 'unref', "valacef.h")

base_refcounted = repo.structs['cef_base_ref_counted_t']
base_refcounted.add_method(ref_func)
base_refcounted.add_method(unref_func)
base_refcounted.set_ref_counting(ref_func.c_name, unref_func.c_name)

ref_func = Function('cef_base_ref_counted_ref', 'ref', "capi/cef_base_capi.h",
                    params=[("cef_base_ref_counted_t*", "self")],
                    body=['self->add_ref(self); return self;'],
                    ret_type="void*")
unref_func = Function('cef_base_ref_counted_unref', 'unref', "capi/cef_base_capi.h",
                      params=[("cef_base_ref_counted_t*", "self")],
                      body=['self->release(self);'])
parser.add_c_glue(ref_func, unref_func)

add_ref_func = Function(
    'cef_base_ref_counted_add_ref', 'base_ref_counted_add_ref', 'capi/cef_base_capi.h;stdio.h',
    params=[('void*', 'self_ptr')],
    body=[
        'cef_base_ref_counted_t* self = (cef_base_ref_counted_t*) self_ptr;',
        'char* pointer = (char*) self + (self->size - (sizeof(int) > sizeof(void*) ? sizeof(int) : sizeof(void*)));',
        'volatile int* ref_count = (volatile int*) pointer;',
        'printf("%d ++ %d + 1\\n", (int) self->size, *ref_count);',
        'g_atomic_int_inc(ref_count);',
    ])
release_ref_func = Function(
    'cef_base_ref_counted_release_ref', 'base_ref_counted_release_ref', 'stdlib.h;capi/cef_base_capi.h;stdio.h', 'int',
    params=[('void*', 'self_ptr')],
    body=[
        'gboolean is_dead = FALSE;'
        'cef_base_ref_counted_t* self = (cef_base_ref_counted_t*) self_ptr;',
        'char* pointer = (char*) self + (self->size - (sizeof(int) > sizeof(void*) ? sizeof(int) : sizeof(void*)));',
        'volatile int* ref_count = (volatile int*) pointer;',
        'printf("%d -- %d - 1\\n", (int) self->size, g_atomic_int_get(ref_count));',
        'is_dead = g_atomic_int_dec_and_test(ref_count);',
        'if (is_dead) {',
        '    printf("%d dealloc!\\n", (int) self->size);',
        '    GData** priv_data = (GData**)(pointer - sizeof(void*));',
        '    g_datalist_clear(priv_data);',
        '    free(self_ptr);',
        '}',
        'return is_dead;'
    ])
has_one_ref_func = Function(
    'cef_base_ref_counted_has_one_ref', 'base_ref_counted_has_one_ref', 'capi/cef_base_capi.h;stdio.h', 'int',
    params=[('void*', 'self_ptr')],
    body=[
        'cef_base_ref_counted_t* self = (cef_base_ref_counted_t*) self_ptr;',
        'char* pointer = (char*) self + (self->size - (sizeof(int) > sizeof(void*) ? sizeof(int) : sizeof(void*)));',
        'volatile int* ref_count = (volatile int*) pointer;',
        'printf("%d ?? %d\\n", (int) self->size, *ref_count);',
        'return g_atomic_int_get(ref_count) == 1;',
    ])
init_refcounting_func = Function(
    'cef_base_ref_counted_init_ref_counting', 'init_refcounting', 'capi/cef_base_capi.h;stdio.h',
    params=[('void*', 'self_ptr'), ('size_t', 'base_size'), ('size_t', 'derived_size')],
    body=[
        'cef_base_ref_counted_t* self = (cef_base_ref_counted_t*) self_ptr;',
        'self->size = derived_size;',
        'self->add_ref = %s;' % add_ref_func.c_name,
        'self->release = %s;' % release_ref_func.c_name,
        'self->has_one_ref = %s;' % has_one_ref_func.c_name,
        'g_assert(base_size + (sizeof(int) > sizeof(void*) ? sizeof(int) : sizeof(void*)) + sizeof(void*) == '
        'derived_size);',
        'char* pointer = (char*) self + (self->size - (sizeof(int) > sizeof(void*) ? sizeof(int) : sizeof(void*)));',
        'volatile int* ref_count = (volatile int*) pointer;',
        'g_atomic_int_set(ref_count, 1);',
        'printf("%d == %d\\n", (int) self->size, *ref_count);',
    ])
parser.add_c_glue(add_ref_func, release_ref_func, has_one_ref_func, init_refcounting_func)

utf16_to_utf8_func = Function(
    'cef_utf16_string_to_vala_string', 'get_string', 'capi/cef_base_capi.h;stdio.h', 'char*',
    params=[('cef_string_t*', 'utf16_str')],
    body=[
        'cef_string_utf8_t utf8_str = {};',
        'cef_string_utf16_to_utf8(utf16_str->str, utf16_str->length, &utf8_str);',
        'return utf8_str.str;',
    ])
parser.add_c_glue(utf16_to_utf8_func)

utf16_to_utf8_func = Function(
    'cef_utf16_string_to_vala_string', 'get_string', 'valacef.h', 'char*',
    params=[('cef_string_t*', 'utf16_str')])
repo.add_function(utf16_to_utf8_func)

utf8_to_utf16_func = Function(
    'cef_utf16_string_from_vala_string', 'set_string', 'string.h;capi/cef_base_capi.h;stdio.h',
    params=[('cef_string_t*', 'utf16_str'), ('char*', 'str')],
    body=[
        'cef_string_utf8_to_utf16(str, strlen(str), utf16_str);',
    ])
parser.add_c_glue(utf8_to_utf16_func)

utf8_to_utf16_func = Function(
    'cef_utf16_string_from_vala_string', 'set_string', 'valacef.h',
    params=[('cef_string_t*', 'utf16_str'), ('char*', 'str')])
repo.add_function(utf8_to_utf16_func)

vapi, vala, c_glue = parser.finish()

os.makedirs("build", exist_ok=True)
with open("build/cef.vapi", "wt") as f:
    f.write(vapi)

with open("build/cef.vala", "wt") as f:
    f.write(vala)

with open("build/valacef.h", "wt") as f:
    f.write(c_glue)
