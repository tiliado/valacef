import os

from valacefgen.cparser import Parser, Naming
from valacefgen.types import Repository

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
]

ignore = {
    'XEvent',
    'XDisplay',
}

parser = Parser(Naming('Cef'), Repository('Cef'), ignore)

for entry in header_files:
    if isinstance(entry, str):
        c_include_path = entry
        path = os.path.join("/app/include/cef/include", entry)
    else:
        path, c_include_path = entry

    parser.parse_header(path, c_include_path)

vapi = parser.repo.__vala__()
print(vapi)
with open("cef.vapi", "wt") as f:
    f.write(vapi)
