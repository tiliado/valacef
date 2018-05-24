namespace CefGtk.UIEvents {

public int get_cef_state_modifiers(uint state) {
    int modifiers = 0;
    if ((state & Gdk.ModifierType.SHIFT_MASK) != 0) {
        modifiers |= Cef.EventFlags.SHIFT_DOWN;
    }
    if ((state & Gdk.ModifierType.LOCK_MASK) != 0) {
        modifiers |= Cef.EventFlags.CAPS_LOCK_ON;
    }
    if ((state & Gdk.ModifierType.CONTROL_MASK) != 0) {
        modifiers |= Cef.EventFlags.CONTROL_DOWN;
    }
    if ((state & Gdk.ModifierType.MOD1_MASK) != 0) {
        modifiers |= Cef.EventFlags.ALT_DOWN;
    }
    if ((state & Gdk.ModifierType.BUTTON1_MASK) != 0) {
        modifiers |= Cef.EventFlags.LEFT_MOUSE_BUTTON;
    }
    if ((state & Gdk.ModifierType.BUTTON2_MASK) != 0) {
        modifiers |= Cef.EventFlags.MIDDLE_MOUSE_BUTTON;
    }
    if ((state & Gdk.ModifierType.BUTTON3_MASK) != 0) {
        modifiers |= Cef.EventFlags.RIGHT_MOUSE_BUTTON;
    }
    return modifiers;
}

public Gdk.ModifierType get_gdk_state_modifiers(uint state) {
    Gdk.ModifierType modifiers = 0;
    if ((state & Cef.EventFlags.SHIFT_DOWN) != 0) {
        modifiers |= Gdk.ModifierType.SHIFT_MASK;
    }
    if ((state & Cef.EventFlags.CAPS_LOCK_ON) != 0) {
        modifiers |= Gdk.ModifierType.LOCK_MASK;
    }
    if ((state & Cef.EventFlags.CONTROL_DOWN) != 0) {
        modifiers |= Gdk.ModifierType.CONTROL_MASK;
    }
    if ((state & Cef.EventFlags.ALT_DOWN) != 0) {
        modifiers |= Gdk.ModifierType.MOD1_MASK;
    }
    if ((state & Cef.EventFlags.LEFT_MOUSE_BUTTON) != 0) {
        modifiers |= Gdk.ModifierType.BUTTON1_MASK;
    }
    if ((state & Cef.EventFlags.MIDDLE_MOUSE_BUTTON) != 0) {
        modifiers |= Gdk.ModifierType.BUTTON2_MASK;
    }
    if ((state & Cef.EventFlags.RIGHT_MOUSE_BUTTON) != 0) {
        modifiers |= Gdk.ModifierType.BUTTON3_MASK;
    }
    return modifiers;
}

// From ui/events/keycodes/keyboard_codes_posix.h.
public enum KeyboardCode {
    VKEY_BACK = 0x08,
    VKEY_TAB = 0x09,
    VKEY_BACKTAB = 0x0A,
    VKEY_CLEAR = 0x0C,
    VKEY_RETURN = 0x0D,
    VKEY_SHIFT = 0x10,
    VKEY_CONTROL = 0x11,
    VKEY_MENU = 0x12,
    VKEY_PAUSE = 0x13,
    VKEY_CAPITAL = 0x14,
    VKEY_KANA = 0x15,
    VKEY_HANGUL = 0x15,
    VKEY_JUNJA = 0x17,
    VKEY_FINAL = 0x18,
    VKEY_HANJA = 0x19,
    VKEY_KANJI = 0x19,
    VKEY_ESCAPE = 0x1B,
    VKEY_CONVERT = 0x1C,
    VKEY_NONCONVERT = 0x1D,
    VKEY_ACCEPT = 0x1E,
    VKEY_MODECHANGE = 0x1F,
    VKEY_SPACE = 0x20,
    VKEY_PRIOR = 0x21,
    VKEY_NEXT = 0x22,
    VKEY_END = 0x23,
    VKEY_HOME = 0x24,
    VKEY_LEFT = 0x25,
    VKEY_UP = 0x26,
    VKEY_RIGHT = 0x27,
    VKEY_DOWN = 0x28,
    VKEY_SELECT = 0x29,
    VKEY_PRINT = 0x2A,
    VKEY_EXECUTE = 0x2B,
    VKEY_SNAPSHOT = 0x2C,
    VKEY_INSERT = 0x2D,
    VKEY_DELETE = 0x2E,
    VKEY_HELP = 0x2F,
    VKEY_0 = 0x30,
    VKEY_1 = 0x31,
    VKEY_2 = 0x32,
    VKEY_3 = 0x33,
    VKEY_4 = 0x34,
    VKEY_5 = 0x35,
    VKEY_6 = 0x36,
    VKEY_7 = 0x37,
    VKEY_8 = 0x38,
    VKEY_9 = 0x39,
    VKEY_A = 0x41,
    VKEY_B = 0x42,
    VKEY_C = 0x43,
    VKEY_D = 0x44,
    VKEY_E = 0x45,
    VKEY_F = 0x46,
    VKEY_G = 0x47,
    VKEY_H = 0x48,
    VKEY_I = 0x49,
    VKEY_J = 0x4A,
    VKEY_K = 0x4B,
    VKEY_L = 0x4C,
    VKEY_M = 0x4D,
    VKEY_N = 0x4E,
    VKEY_O = 0x4F,
    VKEY_P = 0x50,
    VKEY_Q = 0x51,
    VKEY_R = 0x52,
    VKEY_S = 0x53,
    VKEY_T = 0x54,
    VKEY_U = 0x55,
    VKEY_V = 0x56,
    VKEY_W = 0x57,
    VKEY_X = 0x58,
    VKEY_Y = 0x59,
    VKEY_Z = 0x5A,
    VKEY_LWIN = 0x5B,
    VKEY_COMMAND = VKEY_LWIN,  // Provide the Mac name for convenience.
    VKEY_RWIN = 0x5C,
    VKEY_APPS = 0x5D,
    VKEY_SLEEP = 0x5F,
    VKEY_NUMPAD0 = 0x60,
    VKEY_NUMPAD1 = 0x61,
    VKEY_NUMPAD2 = 0x62,
    VKEY_NUMPAD3 = 0x63,
    VKEY_NUMPAD4 = 0x64,
    VKEY_NUMPAD5 = 0x65,
    VKEY_NUMPAD6 = 0x66,
    VKEY_NUMPAD7 = 0x67,
    VKEY_NUMPAD8 = 0x68,
    VKEY_NUMPAD9 = 0x69,
    VKEY_MULTIPLY = 0x6A,
    VKEY_ADD = 0x6B,
    VKEY_SEPARATOR = 0x6C,
    VKEY_SUBTRACT = 0x6D,
    VKEY_DECIMAL = 0x6E,
    VKEY_DIVIDE = 0x6F,
    VKEY_F1 = 0x70,
    VKEY_F2 = 0x71,
    VKEY_F3 = 0x72,
    VKEY_F4 = 0x73,
    VKEY_F5 = 0x74,
    VKEY_F6 = 0x75,
    VKEY_F7 = 0x76,
    VKEY_F8 = 0x77,
    VKEY_F9 = 0x78,
    VKEY_F10 = 0x79,
    VKEY_F11 = 0x7A,
    VKEY_F12 = 0x7B,
    VKEY_F13 = 0x7C,
    VKEY_F14 = 0x7D,
    VKEY_F15 = 0x7E,
    VKEY_F16 = 0x7F,
    VKEY_F17 = 0x80,
    VKEY_F18 = 0x81,
    VKEY_F19 = 0x82,
    VKEY_F20 = 0x83,
    VKEY_F21 = 0x84,
    VKEY_F22 = 0x85,
    VKEY_F23 = 0x86,
    VKEY_F24 = 0x87,
    VKEY_NUMLOCK = 0x90,
    VKEY_SCROLL = 0x91,
    VKEY_LSHIFT = 0xA0,
    VKEY_RSHIFT = 0xA1,
    VKEY_LCONTROL = 0xA2,
    VKEY_RCONTROL = 0xA3,
    VKEY_LMENU = 0xA4,
    VKEY_RMENU = 0xA5,
    VKEY_BROWSER_BACK = 0xA6,
    VKEY_BROWSER_FORWARD = 0xA7,
    VKEY_BROWSER_REFRESH = 0xA8,
    VKEY_BROWSER_STOP = 0xA9,
    VKEY_BROWSER_SEARCH = 0xAA,
    VKEY_BROWSER_FAVORITES = 0xAB,
    VKEY_BROWSER_HOME = 0xAC,
    VKEY_VOLUME_MUTE = 0xAD,
    VKEY_VOLUME_DOWN = 0xAE,
    VKEY_VOLUME_UP = 0xAF,
    VKEY_MEDIA_NEXT_TRACK = 0xB0,
    VKEY_MEDIA_PREV_TRACK = 0xB1,
    VKEY_MEDIA_STOP = 0xB2,
    VKEY_MEDIA_PLAY_PAUSE = 0xB3,
    VKEY_MEDIA_LAUNCH_MAIL = 0xB4,
    VKEY_MEDIA_LAUNCH_MEDIA_SELECT = 0xB5,
    VKEY_MEDIA_LAUNCH_APP1 = 0xB6,
    VKEY_MEDIA_LAUNCH_APP2 = 0xB7,
    VKEY_OEM_1 = 0xBA,
    VKEY_OEM_PLUS = 0xBB,
    VKEY_OEM_COMMA = 0xBC,
    VKEY_OEM_MINUS = 0xBD,
    VKEY_OEM_PERIOD = 0xBE,
    VKEY_OEM_2 = 0xBF,
    VKEY_OEM_3 = 0xC0,
    VKEY_OEM_4 = 0xDB,
    VKEY_OEM_5 = 0xDC,
    VKEY_OEM_6 = 0xDD,
    VKEY_OEM_7 = 0xDE,
    VKEY_OEM_8 = 0xDF,
    VKEY_OEM_102 = 0xE2,
    VKEY_OEM_103 = 0xE3,  // GTV KEYCODE_MEDIA_REWIND
    VKEY_OEM_104 = 0xE4,  // GTV KEYCODE_MEDIA_FAST_FORWARD
    VKEY_PROCESSKEY = 0xE5,
    VKEY_PACKET = 0xE7,
    VKEY_DBE_SBCSCHAR = 0xF3,
    VKEY_DBE_DBCSCHAR = 0xF4,
    VKEY_ATTN = 0xF6,
    VKEY_CRSEL = 0xF7,
    VKEY_EXSEL = 0xF8,
    VKEY_EREOF = 0xF9,
    VKEY_PLAY = 0xFA,
    VKEY_ZOOM = 0xFB,
    VKEY_NONAME = 0xFC,
    VKEY_PA1 = 0xFD,
    VKEY_OEM_CLEAR = 0xFE,
    VKEY_UNKNOWN = 0,
    
    // POSIX specific VKEYs. Note that as of Windows SDK 7.1, 0x97-9F, 0xD8-DA,
    // and 0xE8 are unassigned.
    VKEY_WLAN = 0x97,
    VKEY_POWER = 0x98,
    VKEY_BRIGHTNESS_DOWN = 0xD8,
    VKEY_BRIGHTNESS_UP = 0xD9,
    VKEY_KBD_BRIGHTNESS_DOWN = 0xDA,
    VKEY_KBD_BRIGHTNESS_UP = 0xE8,
    
    // Windows does not have a specific key code for AltGr. We use the unused 0xE1
    // (VK_OEM_AX) code to represent AltGr, matching the behaviour of Firefox on
    // Linux.
    VKEY_ALTGR = 0xE1,
    // Windows does not have a specific key code for Compose. We use the unused
    // 0xE6 (VK_ICO_CLEAR) code to represent Compose.
    VKEY_COMPOSE = 0xE6,
}

// From ui/events/keycodes/keyboard_code_conversion_x.cc.
// Gdk key codes (e.g. GDK_BackSpace) and X keysyms (e.g. Gdk.Key.BackSpace) share
// the same values.
public KeyboardCode keyboard_code_from_x_keysym(uint keysym) {
  switch (keysym) {
    case Gdk.Key.BackSpace:
      return KeyboardCode.VKEY_BACK;
    case Gdk.Key.Delete:
    case Gdk.Key.KP_Delete:
      return KeyboardCode.VKEY_DELETE;
    case Gdk.Key.Tab:
    case Gdk.Key.KP_Tab:
    case Gdk.Key.ISO_Left_Tab:
    case Gdk.Key.3270_BackTab:
      return KeyboardCode.VKEY_TAB;
    case Gdk.Key.Linefeed:
    case Gdk.Key.Return:
    case Gdk.Key.KP_Enter:
    case Gdk.Key.ISO_Enter:
      return KeyboardCode.VKEY_RETURN;
    case Gdk.Key.Clear:
    case Gdk.Key.KP_Begin:  // NumPad 5 without Num Lock, for crosbug.com/29169.
      return KeyboardCode.VKEY_CLEAR;
    case Gdk.Key.KP_Space:
    case Gdk.Key.space:
      return KeyboardCode.VKEY_SPACE;
    case Gdk.Key.Home:
    case Gdk.Key.KP_Home:
      return KeyboardCode.VKEY_HOME;
    case Gdk.Key.End:
    case Gdk.Key.KP_End:
      return KeyboardCode.VKEY_END;
    case Gdk.Key.Page_Up:
    case Gdk.Key.KP_Page_Up:  // aka Gdk.Key.KP_Prior
      return KeyboardCode.VKEY_PRIOR;
    case Gdk.Key.Page_Down:
    case Gdk.Key.KP_Page_Down:  // aka Gdk.Key.KP_Next
      return KeyboardCode.VKEY_NEXT;
    case Gdk.Key.Left:
    case Gdk.Key.KP_Left:
      return KeyboardCode.VKEY_LEFT;
    case Gdk.Key.Right:
    case Gdk.Key.KP_Right:
      return KeyboardCode.VKEY_RIGHT;
    case Gdk.Key.Down:
    case Gdk.Key.KP_Down:
      return KeyboardCode.VKEY_DOWN;
    case Gdk.Key.Up:
    case Gdk.Key.KP_Up:
      return KeyboardCode.VKEY_UP;
    case Gdk.Key.Escape:
      return KeyboardCode.VKEY_ESCAPE;
    case Gdk.Key.Kana_Lock:
    case Gdk.Key.Kana_Shift:
      return KeyboardCode.VKEY_KANA;
    case Gdk.Key.Hangul:
      return KeyboardCode.VKEY_HANGUL;
    case Gdk.Key.Hangul_Hanja:
      return KeyboardCode.VKEY_HANJA;
    case Gdk.Key.Kanji:
      return KeyboardCode.VKEY_KANJI;
    case Gdk.Key.Henkan:
      return KeyboardCode.VKEY_CONVERT;
    case Gdk.Key.Muhenkan:
      return KeyboardCode.VKEY_NONCONVERT;
    case Gdk.Key.Zenkaku_Hankaku:
      return KeyboardCode.VKEY_DBE_DBCSCHAR;
    case Gdk.Key.A:
    case Gdk.Key.a:
      return KeyboardCode.VKEY_A;
    case Gdk.Key.B:
    case Gdk.Key.b:
      return KeyboardCode.VKEY_B;
    case Gdk.Key.C:
    case Gdk.Key.c:
      return KeyboardCode.VKEY_C;
    case Gdk.Key.D:
    case Gdk.Key.d:
      return KeyboardCode.VKEY_D;
    case Gdk.Key.E:
    case Gdk.Key.e:
      return KeyboardCode.VKEY_E;
    case Gdk.Key.F:
    case Gdk.Key.f:
      return KeyboardCode.VKEY_F;
    case Gdk.Key.G:
    case Gdk.Key.g:
      return KeyboardCode.VKEY_G;
    case Gdk.Key.H:
    case Gdk.Key.h:
      return KeyboardCode.VKEY_H;
    case Gdk.Key.I:
    case Gdk.Key.i:
      return KeyboardCode.VKEY_I;
    case Gdk.Key.J:
    case Gdk.Key.j:
      return KeyboardCode.VKEY_J;
    case Gdk.Key.K:
    case Gdk.Key.k:
      return KeyboardCode.VKEY_K;
    case Gdk.Key.L:
    case Gdk.Key.l:
      return KeyboardCode.VKEY_L;
    case Gdk.Key.M:
    case Gdk.Key.m:
      return KeyboardCode.VKEY_M;
    case Gdk.Key.N:
    case Gdk.Key.n:
      return KeyboardCode.VKEY_N;
    case Gdk.Key.O:
    case Gdk.Key.o:
      return KeyboardCode.VKEY_O;
    case Gdk.Key.P:
    case Gdk.Key.p:
      return KeyboardCode.VKEY_P;
    case Gdk.Key.Q:
    case Gdk.Key.q:
      return KeyboardCode.VKEY_Q;
    case Gdk.Key.R:
    case Gdk.Key.r:
      return KeyboardCode.VKEY_R;
    case Gdk.Key.S:
    case Gdk.Key.s:
      return KeyboardCode.VKEY_S;
    case Gdk.Key.T:
    case Gdk.Key.t:
      return KeyboardCode.VKEY_T;
    case Gdk.Key.U:
    case Gdk.Key.u:
      return KeyboardCode.VKEY_U;
    case Gdk.Key.V:
    case Gdk.Key.v:
      return KeyboardCode.VKEY_V;
    case Gdk.Key.W:
    case Gdk.Key.w:
      return KeyboardCode.VKEY_W;
    case Gdk.Key.X:
    case Gdk.Key.x:
      return KeyboardCode.VKEY_X;
    case Gdk.Key.Y:
    case Gdk.Key.y:
      return KeyboardCode.VKEY_Y;
    case Gdk.Key.Z:
    case Gdk.Key.z:
      return KeyboardCode.VKEY_Z;

    case Gdk.Key.@0:
    case Gdk.Key.@1:
    case Gdk.Key.@2:
    case Gdk.Key.@3:
    case Gdk.Key.@4:
    case Gdk.Key.@5:
    case Gdk.Key.@6:
    case Gdk.Key.@7:
    case Gdk.Key.@8:
    case Gdk.Key.@9:
      return (KeyboardCode)(KeyboardCode.VKEY_0 + (keysym - Gdk.Key.@0));

    case Gdk.Key.parenright:
      return KeyboardCode.VKEY_0;
    case Gdk.Key.exclam:
      return KeyboardCode.VKEY_1;
    case Gdk.Key.at:
      return KeyboardCode.VKEY_2;
    case Gdk.Key.numbersign:
      return KeyboardCode.VKEY_3;
    case Gdk.Key.dollar:
      return KeyboardCode.VKEY_4;
    case Gdk.Key.percent:
      return KeyboardCode.VKEY_5;
    case Gdk.Key.asciicircum:
      return KeyboardCode.VKEY_6;
    case Gdk.Key.ampersand:
      return KeyboardCode.VKEY_7;
    case Gdk.Key.asterisk:
      return KeyboardCode.VKEY_8;
    case Gdk.Key.parenleft:
      return KeyboardCode.VKEY_9;

    case Gdk.Key.KP_0:
    case Gdk.Key.KP_1:
    case Gdk.Key.KP_2:
    case Gdk.Key.KP_3:
    case Gdk.Key.KP_4:
    case Gdk.Key.KP_5:
    case Gdk.Key.KP_6:
    case Gdk.Key.KP_7:
    case Gdk.Key.KP_8:
    case Gdk.Key.KP_9:
      return (KeyboardCode)(KeyboardCode.VKEY_NUMPAD0 + (keysym - Gdk.Key.KP_0));

    case Gdk.Key.multiply:
    case Gdk.Key.KP_Multiply:
      return KeyboardCode.VKEY_MULTIPLY;
    case Gdk.Key.KP_Add:
      return KeyboardCode.VKEY_ADD;
    case Gdk.Key.KP_Separator:
      return KeyboardCode.VKEY_SEPARATOR;
    case Gdk.Key.KP_Subtract:
      return KeyboardCode.VKEY_SUBTRACT;
    case Gdk.Key.KP_Decimal:
      return KeyboardCode.VKEY_DECIMAL;
    case Gdk.Key.KP_Divide:
      return KeyboardCode.VKEY_DIVIDE;
    case Gdk.Key.KP_Equal:
    case Gdk.Key.equal:
    case Gdk.Key.plus:
      return KeyboardCode.VKEY_OEM_PLUS;
    case Gdk.Key.comma:
    case Gdk.Key.less:
      return KeyboardCode.VKEY_OEM_COMMA;
    case Gdk.Key.minus:
    case Gdk.Key.underscore:
      return KeyboardCode.VKEY_OEM_MINUS;
    case Gdk.Key.greater:
    case Gdk.Key.period:
      return KeyboardCode.VKEY_OEM_PERIOD;
    case Gdk.Key.colon:
    case Gdk.Key.semicolon:
      return KeyboardCode.VKEY_OEM_1;
    case Gdk.Key.question:
    case Gdk.Key.slash:
      return KeyboardCode.VKEY_OEM_2;
    case Gdk.Key.asciitilde:
    case Gdk.Key.quoteleft:
      return KeyboardCode.VKEY_OEM_3;
    case Gdk.Key.bracketleft:
    case Gdk.Key.braceleft:
      return KeyboardCode.VKEY_OEM_4;
    case Gdk.Key.backslash:
    case Gdk.Key.bar:
      return KeyboardCode.VKEY_OEM_5;
    case Gdk.Key.bracketright:
    case Gdk.Key.braceright:
      return KeyboardCode.VKEY_OEM_6;
    case Gdk.Key.quoteright:
    case Gdk.Key.quotedbl:
      return KeyboardCode.VKEY_OEM_7;
    case Gdk.Key.ISO_Level5_Shift:
      return KeyboardCode.VKEY_OEM_8;
    case Gdk.Key.Shift_L:
    case Gdk.Key.Shift_R:
      return KeyboardCode.VKEY_SHIFT;
    case Gdk.Key.Control_L:
    case Gdk.Key.Control_R:
      return KeyboardCode.VKEY_CONTROL;
    case Gdk.Key.Meta_L:
    case Gdk.Key.Meta_R:
    case Gdk.Key.Alt_L:
    case Gdk.Key.Alt_R:
      return KeyboardCode.VKEY_MENU;
    case Gdk.Key.ISO_Level3_Shift:
      return KeyboardCode.VKEY_ALTGR;
    case Gdk.Key.Multi_key:
      return KeyboardCode.VKEY_COMPOSE;
    case Gdk.Key.Pause:
      return KeyboardCode.VKEY_PAUSE;
    case Gdk.Key.Caps_Lock:
      return KeyboardCode.VKEY_CAPITAL;
    case Gdk.Key.Num_Lock:
      return KeyboardCode.VKEY_NUMLOCK;
    case Gdk.Key.Scroll_Lock:
      return KeyboardCode.VKEY_SCROLL;
    case Gdk.Key.Select:
      return KeyboardCode.VKEY_SELECT;
    case Gdk.Key.Print:
      return KeyboardCode.VKEY_PRINT;
    case Gdk.Key.Execute:
      return KeyboardCode.VKEY_EXECUTE;
    case Gdk.Key.Insert:
    case Gdk.Key.KP_Insert:
      return KeyboardCode.VKEY_INSERT;
    case Gdk.Key.Help:
      return KeyboardCode.VKEY_HELP;
    case Gdk.Key.Super_L:
      return KeyboardCode.VKEY_LWIN;
    case Gdk.Key.Super_R:
      return KeyboardCode.VKEY_RWIN;
    case Gdk.Key.Menu:
      return KeyboardCode.VKEY_APPS;
    case Gdk.Key.F1:
    case Gdk.Key.F2:
    case Gdk.Key.F3:
    case Gdk.Key.F4:
    case Gdk.Key.F5:
    case Gdk.Key.F6:
    case Gdk.Key.F7:
    case Gdk.Key.F8:
    case Gdk.Key.F9:
    case Gdk.Key.F10:
    case Gdk.Key.F11:
    case Gdk.Key.F12:
    case Gdk.Key.F13:
    case Gdk.Key.F14:
    case Gdk.Key.F15:
    case Gdk.Key.F16:
    case Gdk.Key.F17:
    case Gdk.Key.F18:
    case Gdk.Key.F19:
    case Gdk.Key.F20:
    case Gdk.Key.F21:
    case Gdk.Key.F22:
    case Gdk.Key.F23:
    case Gdk.Key.F24:
      return (KeyboardCode)(KeyboardCode.VKEY_F1 + (keysym - Gdk.Key.F1));
    case Gdk.Key.KP_F1:
    case Gdk.Key.KP_F2:
    case Gdk.Key.KP_F3:
    case Gdk.Key.KP_F4:
      return (KeyboardCode)(KeyboardCode.VKEY_F1 + (keysym - Gdk.Key.KP_F1));

    case Gdk.Key.guillemotleft:
    case Gdk.Key.guillemotright:
    case Gdk.Key.degree:
    // In the case of canadian multilingual keyboard layout, VKEY_OEM_102 is
    // assigned to ugrave key.
    case Gdk.Key.ugrave:
    case Gdk.Key.Ugrave:
    case Gdk.Key.brokenbar:
      return KeyboardCode.VKEY_OEM_102;  // international backslash key in 102 keyboard.

    // When evdev is in use, /usr/share/X11/xkb/symbols/inet maps F13-18 keys
    // to the special XF86XK symbols to support Microsoft Ergonomic keyboards:
    // https://bugs.freedesktop.org/show_bug.cgi?id=5783
    // In Chrome, we map these X key symbols back to F13-18 since we don't have
    // VKEYs for these XF86XK symbols.
    case Gdk.Key.Tools:
      return KeyboardCode.VKEY_F13;
    case Gdk.Key.Launch5:
      return KeyboardCode.VKEY_F14;
    case Gdk.Key.Launch6:
      return KeyboardCode.VKEY_F15;
    case Gdk.Key.Launch7:
      return KeyboardCode.VKEY_F16;
    case Gdk.Key.Launch8:
      return KeyboardCode.VKEY_F17;
    case Gdk.Key.Launch9:
      return KeyboardCode.VKEY_F18;
    case Gdk.Key.Refresh:
    case Gdk.Key.History:
    case Gdk.Key.OpenURL:
    case Gdk.Key.AddFavorite:
    case Gdk.Key.Go:
    case Gdk.Key.ZoomIn:
    case Gdk.Key.ZoomOut:
      // ui::AcceleratorGtk tries to convert the Gdk.Key. keysyms on Chrome
      // startup. It's safe to return KeyboardCode.VKEY_UNKNOWN here since ui::AcceleratorGtk
      // also checks a Gdk keysym. http://crbug.com/109843
      return KeyboardCode.VKEY_UNKNOWN;
    // For supporting multimedia buttons on a USB keyboard.
    case Gdk.Key.Back:
      return KeyboardCode.VKEY_BROWSER_BACK;
    case Gdk.Key.Forward:
      return KeyboardCode.VKEY_BROWSER_FORWARD;
    case Gdk.Key.Reload:
      return KeyboardCode.VKEY_BROWSER_REFRESH;
    case Gdk.Key.Stop:
      return KeyboardCode.VKEY_BROWSER_STOP;
    case Gdk.Key.Search:
      return KeyboardCode.VKEY_BROWSER_SEARCH;
    case Gdk.Key.Favorites:
      return KeyboardCode.VKEY_BROWSER_FAVORITES;
    case Gdk.Key.HomePage:
      return KeyboardCode.VKEY_BROWSER_HOME;
    case Gdk.Key.AudioMute:
      return KeyboardCode.VKEY_VOLUME_MUTE;
    case Gdk.Key.AudioLowerVolume:
      return KeyboardCode.VKEY_VOLUME_DOWN;
    case Gdk.Key.AudioRaiseVolume:
      return KeyboardCode.VKEY_VOLUME_UP;
    case Gdk.Key.AudioNext:
      return KeyboardCode.VKEY_MEDIA_NEXT_TRACK;
    case Gdk.Key.AudioPrev:
      return KeyboardCode.VKEY_MEDIA_PREV_TRACK;
    case Gdk.Key.AudioStop:
      return KeyboardCode.VKEY_MEDIA_STOP;
    case Gdk.Key.AudioPlay:
      return KeyboardCode.VKEY_MEDIA_PLAY_PAUSE;
    case Gdk.Key.Mail:
      return KeyboardCode.VKEY_MEDIA_LAUNCH_MAIL;
    case Gdk.Key.LaunchA:  // F3 on an Apple keyboard.
      return KeyboardCode.VKEY_MEDIA_LAUNCH_APP1;
    case Gdk.Key.LaunchB:  // F4 on an Apple keyboard.
    case Gdk.Key.Calculator:
      return KeyboardCode.VKEY_MEDIA_LAUNCH_APP2;
    case Gdk.Key.WLAN:
      return KeyboardCode.VKEY_WLAN;
    case Gdk.Key.PowerOff:
      return KeyboardCode.VKEY_POWER;
    case Gdk.Key.MonBrightnessDown:
      return KeyboardCode.VKEY_BRIGHTNESS_DOWN;
    case Gdk.Key.MonBrightnessUp:
      return KeyboardCode.VKEY_BRIGHTNESS_UP;
    case Gdk.Key.KbdBrightnessDown:
      return KeyboardCode.VKEY_KBD_BRIGHTNESS_DOWN;
    case Gdk.Key.KbdBrightnessUp:
      return KeyboardCode.VKEY_KBD_BRIGHTNESS_UP;

      // TODO(sad): some keycodes are still missing.
  }
  return KeyboardCode.VKEY_UNKNOWN;
}

// From content/browser/renderer_host/input/web_input_event_util_posix.cc.
public KeyboardCode gdk_event_to_windows_keycode(Gdk.EventKey event) {
  int[] hardware_code_to_gdk_keyval = {
      0,                 // 0x00:
      0,                 // 0x01:
      0,                 // 0x02:
      0,                 // 0x03:
      0,                 // 0x04:
      0,                 // 0x05:
      0,                 // 0x06:
      0,                 // 0x07:
      0,                 // 0x08:
      0,                 // 0x09: GDK_Escape
      Gdk.Key.@1,             // 0x0A: GDK_1
      Gdk.Key.@2,             // 0x0B: GDK_2
      Gdk.Key.@3,             // 0x0C: GDK_3
      Gdk.Key.@4,             // 0x0D: GDK_4
      Gdk.Key.@5,             // 0x0E: GDK_5
      Gdk.Key.@6,             // 0x0F: GDK_6
      Gdk.Key.@7,             // 0x10: GDK_7
      Gdk.Key.@8,             // 0x11: GDK_8
      Gdk.Key.@9,             // 0x12: GDK_9
      Gdk.Key.@0,             // 0x13: GDK_0
      Gdk.Key.minus,         // 0x14: GDK_minus
      Gdk.Key.equal,         // 0x15: GDK_equal
      0,                 // 0x16: GDK_BackSpace
      0,                 // 0x17: GDK_Tab
      Gdk.Key.q,             // 0x18: GDK_q
      Gdk.Key.w,             // 0x19: GDK_w
      Gdk.Key.e,             // 0x1A: GDK_e
      Gdk.Key.r,             // 0x1B: GDK_r
      Gdk.Key.t,             // 0x1C: GDK_t
      Gdk.Key.y,             // 0x1D: GDK_y
      Gdk.Key.u,             // 0x1E: GDK_u
      Gdk.Key.i,             // 0x1F: GDK_i
      Gdk.Key.o,             // 0x20: GDK_o
      Gdk.Key.p,             // 0x21: GDK_p
      Gdk.Key.bracketleft,   // 0x22: GDK_bracketleft
      Gdk.Key.bracketright,  // 0x23: GDK_bracketright
      0,                 // 0x24: GDK_Return
      0,                 // 0x25: GDK_Control_L
      Gdk.Key.a,             // 0x26: GDK_a
      Gdk.Key.s,             // 0x27: GDK_s
      Gdk.Key.d,             // 0x28: GDK_d
      Gdk.Key.f,             // 0x29: GDK_f
      Gdk.Key.g,             // 0x2A: GDK_g
      Gdk.Key.h,             // 0x2B: GDK_h
      Gdk.Key.j,             // 0x2C: GDK_j
      Gdk.Key.k,             // 0x2D: GDK_k
      Gdk.Key.l,             // 0x2E: GDK_l
      Gdk.Key.semicolon,     // 0x2F: GDK_semicolon
      Gdk.Key.apostrophe,    // 0x30: GDK_apostrophe
      Gdk.Key.grave,         // 0x31: GDK_grave
      0,                 // 0x32: GDK_Shift_L
      Gdk.Key.backslash,     // 0x33: GDK_backslash
      Gdk.Key.z,             // 0x34: GDK_z
      Gdk.Key.x,             // 0x35: GDK_x
      Gdk.Key.c,             // 0x36: GDK_c
      Gdk.Key.v,             // 0x37: GDK_v
      Gdk.Key.b,             // 0x38: GDK_b
      Gdk.Key.n,             // 0x39: GDK_n
      Gdk.Key.m,             // 0x3A: GDK_m
      Gdk.Key.comma,         // 0x3B: GDK_comma
      Gdk.Key.period,        // 0x3C: GDK_period
      Gdk.Key.slash,         // 0x3D: GDK_slash
      0,                 // 0x3E: GDK_Shift_R
      0,                 // 0x3F:
      0,                 // 0x40:
      0,                 // 0x41:
      0,                 // 0x42:
      0,                 // 0x43:
      0,                 // 0x44:
      0,                 // 0x45:
      0,                 // 0x46:
      0,                 // 0x47:
      0,                 // 0x48:
      0,                 // 0x49:
      0,                 // 0x4A:
      0,                 // 0x4B:
      0,                 // 0x4C:
      0,                 // 0x4D:
      0,                 // 0x4E:
      0,                 // 0x4F:
      0,                 // 0x50:
      0,                 // 0x51:
      0,                 // 0x52:
      0,                 // 0x53:
      0,                 // 0x54:
      0,                 // 0x55:
      0,                 // 0x56:
      0,                 // 0x57:
      0,                 // 0x58:
      0,                 // 0x59:
      0,                 // 0x5A:
      0,                 // 0x5B:
      0,                 // 0x5C:
      0,                 // 0x5D:
      0,                 // 0x5E:
      0,                 // 0x5F:
      0,                 // 0x60:
      0,                 // 0x61:
      0,                 // 0x62:
      0,                 // 0x63:
      0,                 // 0x64:
      0,                 // 0x65:
      0,                 // 0x66:
      0,                 // 0x67:
      0,                 // 0x68:
      0,                 // 0x69:
      0,                 // 0x6A:
      0,                 // 0x6B:
      0,                 // 0x6C:
      0,                 // 0x6D:
      0,                 // 0x6E:
      0,                 // 0x6F:
      0,                 // 0x70:
      0,                 // 0x71:
      0,                 // 0x72:
      Gdk.Key.Super_L,       // 0x73: GDK_Super_L
      Gdk.Key.Super_R,       // 0x74: GDK_Super_R
  };

  // |windows_key_code| has to include a valid virtual-key code even when we
  // use non-US layouts, e.g. even when we type an 'A' key of a US keyboard
  // on the Hebrew layout, |windows_key_code| should be VK_A.
  // On the other hand, |event->keyval| value depends on the current
  // GdkKeymap object, i.e. when we type an 'A' key of a US keyboard on
  // the Hebrew layout, |event->keyval| becomes GDK_hebrew_shin and this
  // KeyboardCodeFromXKeysym() call returns 0.
  // To improve compatibilty with Windows, we use |event->hardware_keycode|
  // for retrieving its Windows key-code for the keys when the
  // WebCore::windows_key_codeForEvent() call returns 0.
  // We shouldn't use |event->hardware_keycode| for keys that GdkKeymap
  // objects cannot change because |event->hardware_keycode| doesn't change
  // even when we change the layout options, e.g. when we swap a control
  // key and a caps-lock key, GTK doesn't swap their
  // |event->hardware_keycode| values but swap their |event->keyval| values.
  KeyboardCode windows_key_code = keyboard_code_from_x_keysym(event.keyval);
  if (windows_key_code > 0)
    return windows_key_code;

  if (event.hardware_keycode < hardware_code_to_gdk_keyval.length) {
    int keyval = hardware_code_to_gdk_keyval[event.hardware_keycode];
    if (keyval > 0)
      return keyboard_code_from_x_keysym(keyval);
  }

  // This key is one that keyboard-layout drivers cannot change.
  // Use |event->keyval| to retrieve its |windows_key_code| value.
  return keyboard_code_from_x_keysym(event.keyval);
}

// From content/browser/renderer_host/input/web_input_event_util_posix.cc.
public KeyboardCode get_windows_keycode_without_location(KeyboardCode key_code) {
  switch (key_code) {
    case KeyboardCode.VKEY_LCONTROL:
    case KeyboardCode.VKEY_RCONTROL:
      return KeyboardCode.VKEY_CONTROL;
    case KeyboardCode.VKEY_LSHIFT:
    case KeyboardCode.VKEY_RSHIFT:
      return KeyboardCode.VKEY_SHIFT;
    case KeyboardCode.VKEY_LMENU:
    case KeyboardCode.VKEY_RMENU:
      return KeyboardCode.VKEY_MENU;
    default:
      return key_code;
  }
}

// From content/browser/renderer_host/input/web_input_event_builders_gtk.cc.
// Gets the corresponding control character of a specified key code. See:
// http://en.wikipedia.org/wiki/Control_characters
// We emulate Windows behavior here.
public int get_control_character(KeyboardCode windows_key_code, bool shift) {
  if (windows_key_code >= KeyboardCode.VKEY_A && windows_key_code <= KeyboardCode.VKEY_Z) {
    // ctrl-A ~ ctrl-Z map to \x01 ~ \x1A
    return windows_key_code - KeyboardCode.VKEY_A + 1;
  }
  if (shift) {
    // following graphics chars require shift key to input.
    switch (windows_key_code) {
      // ctrl-@ maps to \x00 (Null byte)
      case KeyboardCode.VKEY_2:
        return 0;
      // ctrl-^ maps to \x1E (Record separator, Information separator two)
      case KeyboardCode.VKEY_6:
        return 0x1E;
      // ctrl-_ maps to \x1F (Unit separator, Information separator one)
      case KeyboardCode.VKEY_OEM_MINUS:
        return 0x1F;
      // Returns 0 for all other keys to avoid inputting unexpected chars.
      default:
        return 0;
    }
  } else {
    switch (windows_key_code) {
      // ctrl-[ maps to \x1B (Escape)
      case KeyboardCode.VKEY_OEM_4:
        return 0x1B;
      // ctrl-\ maps to \x1C (File separator, Information separator four)
      case KeyboardCode.VKEY_OEM_5:
        return 0x1C;
      // ctrl-] maps to \x1D (Group separator, Information separator three)
      case KeyboardCode.VKEY_OEM_6:
        return 0x1D;
      // ctrl-Enter maps to \x0A (Line feed)
      case KeyboardCode.VKEY_RETURN:
        return 0x0A;
      // Returns 0 for all other keys to avoid inputting unexpected chars.
      default:
        return 0;
    }
  }
}

public void send_click_event(Gdk.EventButton event, Cef.BrowserHost host, int scale_factor) {
    Cef.MouseButtonType button_type;
    switch (event.button) {
    case 1:
        button_type = Cef.MouseButtonType.LEFT;
        break;
    case 2:
        button_type = Cef.MouseButtonType.MIDDLE;
        break;
    case 3:
        button_type = Cef.MouseButtonType.RIGHT;
        break;
    default:
        // Other mouse buttons are not handled here.
        return;
    }

    Cef.MouseEvent mouse = {};
    mouse.x = (int) event.x / scale_factor;
    mouse.y = (int) event.y / scale_factor;
//~         self->ApplyPopupOffset(mouse_event.x, mouse_event.y);
    mouse.modifiers = get_cef_state_modifiers(event.state);

    bool mouse_up = event.type == Gdk.EventType.BUTTON_RELEASE;
    int click_count;
    switch (event.type) {
    case Gdk.EventType.2BUTTON_PRESS:
        click_count = 2;
        break;
    case Gdk.EventType.3BUTTON_PRESS:
        click_count = 3;
        break;
    default:
        click_count = 1;
        break;
    }
    host.send_mouse_click_event(mouse, button_type, (int) mouse_up, click_count);

//~       // Save mouse event that can be a possible trigger for drag.
//~       if (!self->drag_context_ && button_type == MBT_LEFT) {
//~         if (self->drag_trigger_event_) {
//~           gdk_event_free(self->drag_trigger_event_);
//~         }
//~         self->drag_trigger_event_ =
//~             gdk_event_copy(reinterpret_cast<GdkEvent*>(event));
//~       }
}

public void send_scroll_event(Gdk.EventScroll event, Cef.BrowserHost host, int scale_factor) {
    Cef.MouseEvent mouse = {};
    mouse.x = (int) event.x / scale_factor;
    mouse.y = (int) event.y / scale_factor;
//~         self->ApplyPopupOffset(mouse_event.x, mouse_event.y);
    mouse.modifiers = get_cef_state_modifiers(event.state);
    const int SCROLLBAR_PIXELS_PER_GTK_TICK = 40;
    int dx = 0;
    int dy = 0;
    switch (event.direction) {
    case Gdk.ScrollDirection.UP:
        dy = 1;
        break;
    case Gdk.ScrollDirection.DOWN:
        dy = -1;
        break;
    case Gdk.ScrollDirection.LEFT:
        dx = 1;
        break;
    case Gdk.ScrollDirection.RIGHT:
        dx = -1;
        break;
    }
    host.send_mouse_wheel_event(mouse, dx * SCROLLBAR_PIXELS_PER_GTK_TICK, dy * SCROLLBAR_PIXELS_PER_GTK_TICK);
}

public void send_key_event(Gdk.EventKey event, Cef.BrowserHost host) {
    Cef.KeyEvent key = {};
    KeyboardCode windows_keycode = gdk_event_to_windows_keycode(event);
    key.windows_key_code = get_windows_keycode_without_location(windows_keycode);
    key.native_key_code = event.hardware_keycode;
    key.modifiers = get_cef_state_modifiers(event.state);
    if (event.keyval >= Gdk.Key.KP_Space && event.keyval <= Gdk.Key.KP_9) {
        key.modifiers |= Cef.EventFlags.IS_KEY_PAD;
    }
    if ((key.modifiers & Cef.EventFlags.ALT_DOWN) != 0) {
        key.is_system_key = 1;
    }
    if (windows_keycode == KeyboardCode.VKEY_RETURN) {
        // We need to treat the enter key as a key press of character \r.  This
        // is apparently just how webkit handles it and what it expects.
        key.unmodified_character = '\r';
    } else {
        // FIXME: fix for non BMP chars
        key.unmodified_character = (Cef.Char16) Gdk.keyval_to_unicode(event.keyval);
    }
    // If ctrl key is pressed down, then control character shall be input.
    if ((key.modifiers & Cef.EventFlags.CONTROL_DOWN) != 0) {
        key.character = (Cef.Char16) get_control_character(
            windows_keycode, (key.modifiers & Cef.EventFlags.SHIFT_DOWN) != 0);
    } else {
        key.character = key.unmodified_character;
    }
    if (event.type == Gdk.EventType.KEY_PRESS) {
        key.type = Cef.KeyEventType.RAWKEYDOWN;
        host.send_key_event(key);
        key.type = Cef.KeyEventType.CHAR;
        host.send_key_event(key);
    } else {
        key.type = Cef.KeyEventType.KEYUP;
        host.send_key_event(key);
    }
}

public void send_motion_event(Gdk.EventMotion event, Cef.BrowserHost host, int scale_factor) {
    int x, y;
    Gdk.ModifierType state;
    if (event.is_hint > 0) {
        event.window.get_pointer(out x, out y, out state);
    } else {
        x = (int) event.x;
        y = (int) event.y;
        state = event.state;
        if (x == 0 && y == 0) {
            // Invalid coordinates of (0,0) appear from time to time in
            // enter-notify-event and leave-notify-event events. Sending them may
            // cause StartDragging to never get called, so just ignore these.
            return;
        }
    }

    Cef.MouseEvent mouse = {};
    mouse.x = x / scale_factor;
    mouse.y = y / scale_factor;
    // self->ApplyPopupOffset(mouse_event.x, mouse_event.y);
    mouse.modifiers = get_cef_state_modifiers(state);
    bool mouse_leave = event.type == Gdk.EventType.LEAVE_NOTIFY;
    host.send_mouse_move_event(mouse, (int) mouse_leave);

//~           // Save mouse event that can be a possible trigger for drag.
//~           if (!self->drag_context_ &&
//~               (mouse_event.modifiers & EVENTFLAG_LEFT_MOUSE_BUTTON)) {
//~             if (self->drag_trigger_event_) {
//~               gdk_event_free(self->drag_trigger_event_);
//~             }
//~             self->drag_trigger_event_ =
//~                 gdk_event_copy(reinterpret_cast<GdkEvent*>(event));
//~           }
}

} // namespace CefGtk.UIEvents
