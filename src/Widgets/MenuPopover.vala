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
    public class Widgets.MenuPopover : Gtk.Popover {

        private Gtk.Grid main_grid;
        private Gtk.ModelButton new_note_button;
        private Gtk.ModelButton rename_note_button;
        private Gtk.ModelButton remove_note_button;

        public signal void add_note_clicked ();
        public signal void remove_note_clicked ();
        public signal void rename_note_clicked ();


        public MenuPopover (Gtk.Widget relative_to) {
            Object (
                relative_to: relative_to
            );

            //TODO -- select colour buttons 

            rename_note_button = new Gtk.ModelButton ();
            //rename_note_button.text = _("Set Title");
            rename_note_button.tooltip_text = _("Rename this note");
            rename_note_button.margin = 5;
            rename_note_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
            
            new_note_button = new Gtk.ModelButton ();
            new_note_button.text = _("Add note");
            new_note_button.tooltip_text = _("Create new note");
            new_note_button.margin = 5;
            new_note_button.action_name = "app.new";
            new_note_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            remove_note_button = new Gtk.ModelButton ();
            remove_note_button.text = _("Delete note");
            remove_note_button.tooltip_text = _("Delete this note");
            remove_note_button.action_name = "app.delete";
            remove_note_button.margin = 5;
            remove_note_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);

            main_grid = new Gtk.Grid ();
            main_grid.margin_bottom = 3;
            main_grid.row_spacing = 5;
            main_grid.orientation = Gtk.Orientation.VERTICAL;
            main_grid.width_request = 150;
            //main_grid.attach(rename_note_button, 0,0,1,1);
            main_grid.attach(new_note_button, 0,0,1,1);
            main_grid.attach(remove_note_button, 0,1,1,1);
            add (main_grid);
            main_grid.show_all ();

            connect_events ();
        }

        private void connect_events () {
            rename_note_button.clicked.connect (() => {
                rename_note_clicked ();
            });
        }
    }
}