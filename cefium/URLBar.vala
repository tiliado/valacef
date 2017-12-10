/*
 * Copyright 2017 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace Cefium {

public class URLBar: Gtk.Grid {
    public Gtk.Entry entry;
    public string? url {
        get {return entry.text;}
        set {entry.text = value;}
    }
    private Gtk.Button go_button;
    
    public URLBar(string? url) {
        orientation = Gtk.Orientation.HORIZONTAL;
        hexpand = true;
        halign = Gtk.Align.FILL;
        margin_start = margin_end = 20;
        get_style_context().add_class("linked");
        entry = new Gtk.Entry();
        if (url != null) {
            entry.text = url;
        }
        entry.hexpand = true;
        entry.halign = Gtk.Align.FILL;
        entry.activate.connect(on_go_button_clicked);
        entry.show();
        add(entry);
        go_button = new Gtk.Button.with_label("Go");
        go_button.clicked.connect(on_go_button_clicked);
        go_button.show();
        add(go_button);
    }
    
    ~URLBar() {
        go_button.clicked.disconnect(on_go_button_clicked);
        entry.activate.disconnect(on_go_button_clicked);
    }
    
    public signal void response(bool accepted);
    
    private void on_go_button_clicked() {
        response(true);
    }
}

} // namespace Cefium
