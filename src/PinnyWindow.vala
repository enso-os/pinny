/*
 * Copyright (c) 2019 Nick Wilkins
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 */

namespace Pinny {
    public class PinnyWindow : Gtk.Window {

        private Gtk.HeaderBar header;
        private Gtk.SourceBuffer buffer;
        private Gtk.SourceView view;
        private Gtk.ToggleButton menu_button;
        private Gtk.Button close_button;
        private Gtk.Button rename_button;
        private Gtk.Button change_colour_button;
        private Widgets.MenuPopover menu_popover;
        private Gtk.Label header_label;
        private Gtk.Entry header_entry;

        private string random_colour;
        private Gee.ArrayList<string> colours; 

        public Backend.Note? note { get; construct set; }

        private bool show_entry = false;

        public signal void add_note ();
        public signal void remove_note (PinnyWindow win);

        public PinnyWindow (Gtk.Application app, int id, Backend.Note? note = null) {
            Object (
                application: app,
                app_paintable: true,
                note: note
            );
            this.set_visual (Gdk.Screen.get_default ().get_rgba_visual ());
            override_font (Pango.FontDescription.from_string ("Fira Code"));

            
            restore_window_position();
            update_window_theme ();
            setup_ui ();
            connect_events ();
        }

        private void setup_ui () {
            random_colour = _("view-%s").printf(note.colour);
            colours = new Gee.ArrayList<string> ();

            colours.add("white");
            colours.add("red");
            colours.add("yellow");
            colours.add("green");
            colours.add("blue");
            colours.add("indigo");
            //colours.add("cocoa");

            //close the note
            close_button = new Gtk.Button ();
            close_button.image = new Gtk.Image.from_icon_name ("window-close-symbolic", Gtk.IconSize.MENU); 
            
            //rename popover button
            rename_button = new Gtk.Button ();
            rename_button.tooltip_text = _("Rename this note");
            rename_button.image = new Gtk.Image.from_icon_name ("edit-symbolic", Gtk.IconSize.MENU);

            //rename popover button
            change_colour_button = new Gtk.Button ();
            change_colour_button.tooltip_text = _("Change note colour");
            change_colour_button.image = new Gtk.Image.from_icon_name ("preferences-color-symbolic", Gtk.IconSize.MENU);

            //menu popover button
            menu_button = new Gtk.ToggleButton ();
            menu_button.image = new Gtk.Image.from_icon_name ("application-menu-symbolic", Gtk.IconSize.MENU);
            
            menu_popover = new Widgets.MenuPopover (menu_button);

            header_label = new Gtk.Label (note.title);

            header_entry = new Gtk.Entry ();
            header_entry.set_text (note.title);
            header_entry.margin_start = 5;
            header_entry.margin_end = 5;
            header_entry.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            
            // create custom heeader bar 
            header = new Gtk.HeaderBar();

            // add settings cog and add button to header bar "Note One"
            if(show_entry)
                header.set_custom_title(header_entry);
            else
                header.set_custom_title(header_label);

            header.pack_start (close_button);
            header.pack_end (menu_button);
            header.pack_end (change_colour_button);
            header.pack_end (rename_button);
            this.set_titlebar(header);
            

            var scrolled = new Gtk.ScrolledWindow (null, null);
            scrolled.set_size_request (450,330);
            scrolled.get_style_context().add_class("mainwindow");

            buffer = new Gtk.SourceBuffer (null);
            view = new Gtk.SourceView.with_buffer (buffer);
            
            view.buffer.text = note.content;
            view.auto_indent = true;
            view.bottom_margin = 10;
            view.get_style_context().add_class(random_colour);
            view.expand = true;
            view.left_margin = 10;
            view.margin = 2;
            view.right_margin = 10;
            view.set_wrap_mode (Gtk.WrapMode.WORD);
            view.top_margin = 10;
            scrolled.add (view);

            var grid = new Gtk.Grid ();
            grid.orientation = Gtk.Orientation.VERTICAL;
            grid.expand = true;
            grid.add (scrolled);
            //grid.add (actionbar);
            grid.show_all ();
            
            add (grid);

            show_all ();
        }

        private void connect_events () {
            close_button.clicked.connect (() => {
                close ();
            });

            menu_button.toggled.connect (() => {
                if(menu_button.active)
                    menu_popover.show ();
            });

            menu_popover.closed.connect (() => {
                menu_button.active = false;
            });

            //  menu_popover.add_note_clicked.connect (() => {
            //      add_note ();
            //      menu_popover.hide ();
            //  });

            //  menu_popover.remove_note_clicked.connect (() => {
            //      remove_note (this);
            //      menu_popover.hide ();
            //  });

            rename_button.clicked.connect (() => {
                show_entry = !show_entry;
                change_header_entry ();
                menu_popover.hide ();
            });

            header_entry.activate.connect (() => {
                note.set_header_title (header_entry.get_text ());
                header_label.set_text (note.title);
                show_entry = !show_entry;
                change_header_entry ();
                menu_popover.hide ();
            });

            header_entry.focus_out_event.connect ((event) => {
                note.set_header_title (header_entry.get_text ());
                header_label.set_text (note.title);
                show_entry = false;
                change_header_entry ();
                menu_popover.hide ();
                return false;
            });

            buffer.changed.connect (() => {
                note.save_note (buffer.text);
            });

            delete_event.connect(() => {
                save_window_position ();
                return false;
            });

            change_colour_button.clicked.connect(() => {
                var id = colours.index_of(random_colour.substring(5));
                
                //remove exitsting class to enable new one
                var old_random_colour = _("view-%s").printf (colours.get(id));
                view.get_style_context().remove_class(old_random_colour);

                id++;

                if(id == colours.size)
                    id=0;

                // apply new colours class
                random_colour = _("view-%s").printf (colours.get(id));
                view.get_style_context().add_class(random_colour);
                note.change_colour (colours.get(id));
            });
        }

        private void change_header_entry () {
            if(show_entry){
                header.set_custom_title(header_entry);
                header_entry.grab_focus ();
            }
            else
                header.set_custom_title(header_label);

            header.show_all ();
        }

        /**
         *  Update window theme.
         */
        private void update_window_theme () {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/org/enso/pinny/application.css");
            Gtk.StyleContext.remove_provider_for_screen (Gdk.Screen.get_default (), provider);     

            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, 600);
        }

         /**
         *  Restore window position.
         */
        public void restore_window_position () {
            debug ("Moving window to coordinates %d, %d", note.x, note.y);
            this.move (note.x, note.y);

            debug ("Resizing to width and height: %d, %d", note.width, note.height);
            this.resize (note.width, note.height);
        }

        /**
         *  Save window position.
         */
        public void save_window_position () {
            int x, y, width, height;
            this.get_position (out x, out y);
            this.get_size (out width, out height);
            debug ("Saving window position to %d, %d", x, y);
            note.set_position (x,y);
            debug ("Saving window size of width and height: %d, %d", width, height);
            note.set_size (width, height);
        }
    }
}
