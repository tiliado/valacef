import os

from valacefgen.cparser import Parser, Naming
from valacefgen.types import Repository, Function

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

parser = Parser(Naming('Cef'), Repository('Cef'), ignore, base_structs, base_classes)

for entry in header_files:
    if isinstance(entry, str):
        c_include_path = entry
        path = os.path.join("/app/include/cef/include", entry)
    else:
        path, c_include_path = entry

    parser.parse_header(path, c_include_path)

repo = parser.repo
ref_func = Function('cef_base_ref_counted_ref', 'ref', "", body=['this.add_ref(this);'])
unref_func = Function('cef_base_ref_counted_unref', 'unref', "", body=['this.release(this);'])

base_refcounted = repo.structs['cef_base_ref_counted_t']
base_refcounted.add_method(ref_func)
base_refcounted.add_method(unref_func)
base_refcounted.set_ref_counting(ref_func.c_name, unref_func.c_name)

atomic_int_inc_func = Function(
    'g_atomic_int_inc', 'atomic_int_inc', '',
    params=[('int*', 'value')],
)

atomic_int_dec_func = Function(
    'g_atomic_int_dec_and_test', 'atomic_int_dec', '', 'bool',
    params=[('int*', 'value')],
)

atomic_int_get_func = Function(
    'g_atomic_int_get', 'atomic_int_get', '', 'int',
    params=[('int*', 'value')],
)

atomic_int_set_func = Function(
    'g_atomic_int_set', 'atomic_int_set', '',
    params=[('int*', 'value'), ('int', 'new_value')],
)

add_ref_func = Function(
    'cef_base_ref_counted_add_ref', 'base_ref_counted_add_ref', '',
    params=[('cef_base_ref_counted_t*', 'self')],
    body=[
        'char* pointer = (char*) self + (self.size - sizeof(int));',
        'int? ref_count = (int?) pointer;',
        '%s(ref_count);' % atomic_int_inc_func.vala_name,
    ])
release_ref_func = Function(
    'cef_base_ref_counted_release_ref', 'base_ref_counted_release_ref', '', 'int',
    params=[('cef_base_ref_counted_t*', 'self')],
    body=[
        'char* pointer = (char*) self + (self.size - sizeof(int));',
        'int? ref_count = (int?) pointer;',
        'return (int) %s(ref_count);' % atomic_int_dec_func.vala_name,
    ])
has_one_ref_func = Function(
    'cef_base_ref_counted_has_one_ref', 'base_ref_counted_has_one_ref', '', 'int',
    params=[('cef_base_ref_counted_t*', 'self')],
    body=[
        'char* pointer = (char*) self + (self.size - sizeof(int));',
        'int? ref_count = (int?) pointer;',
        'return (int) (%s(ref_count) == 1);' % atomic_int_get_func.vala_name,
    ])
init_refcounting_func = Function(
    'cef_base_ref_counted_init_ref_counting', 'init_refcounting', '',
    params=[('cef_base_ref_counted_t*', 'self'), ('size_t', 'base_size'), ('size_t', 'derived_size')],
    body=[
        'self.size = derived_size;',
        'self.add_ref = %s;' % add_ref_func.vala_name,
        'self.release = %s;' % release_ref_func.vala_name,
        'self.has_one_ref = %s;' % has_one_ref_func.vala_name,
        'GLib.assert(base_size + sizeof(int) == derived_size);',
        'char* pointer = (char*) self + (self.size - sizeof(int));',
        'int? ref_count = (int?) pointer;',
        '%s(ref_count, 1000);' % atomic_int_set_func.vala_name,
    ])
repo.add_function(
    init_refcounting_func, add_ref_func, release_ref_func, has_one_ref_func,
    atomic_int_dec_func, atomic_int_get_func, atomic_int_inc_func, atomic_int_set_func)
parser.finish()

vapi = parser.repo.__vala__()

os.makedirs("build", exist_ok=True)
with open("build/cef.vapi", "wt") as f:
    f.write(vapi)
