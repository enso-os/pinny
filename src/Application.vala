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
    public class Application : Gtk.Application {

        public Gee.ArrayList<PinnyWindow> open_windows = new Gee.ArrayList<PinnyWindow>();
        private Backend.EnabledNotesSettings notes_settings = new Backend.EnabledNotesSettings ();
        private Gee.ArrayList<string> existing_notes = new Gee.ArrayList<string> ();

        public SimpleAction quit_action;
        public SimpleAction new_action;
        public SimpleAction delete_action;

        public Application () {
            Object (application_id: "org.enso.pinny");
	    }

        construct {
            var quit_action = new SimpleAction ("quit", null);
            set_accels_for_action ("app.quit", {"<Control>q"});
            add_action (quit_action);
            quit_action.activate.connect (() => {
    	        foreach (PinnyWindow windows in open_windows) {
    	            windows.close();
    	        }
            });
            var new_action = new SimpleAction ("new", null);
            set_accels_for_action ("app.new", {"<Control>n"});
            add_action (new_action);
            new_action.activate.connect (() => {
                create_note(false);
                update_saved_notes();
            });
            var delete_action = new SimpleAction ("delete", null);
            set_accels_for_action ("app.delete", {"<Control>w"});
            add_action (delete_action);
            delete_action.activate.connect (() => {
                PinnyWindow note = (PinnyWindow)get_active_window ();
                remove_note(note);
                note.destroy();
                update_saved_notes();
            });
            existing_notes = new Gee.ArrayList<string>.wrap(notes_settings.enabled_notes);
        }

        protected override void activate () {
            if (get_windows ().length () > 0) {
                foreach (var window in open_windows) {
                    if (window.visible) {
                        window.present ();
                    }
                }
            }

            create_note (true);
	    }

	    public void create_note(bool on_activate) {

            PinnyWindow note_win = null;

            if(existing_notes.size > 0 && on_activate) {
                existing_notes.foreach((note_id) => {
                    var note = new Backend.Note (note_id.to_int());
                    note_win = new PinnyWindow (this, note.id, note);
                    open_windows.add(note_win);
                    return true;
                });
            }
            else {
                var note = new Backend.Note ((int)GLib.Random.int_range (1, 100000));
                note_win = new PinnyWindow (this, note.id, note);
                existing_notes.add (note.id.to_string());
                open_windows.add(note_win);
                update_saved_notes();
            }

            note_win.add_note.connect (() => {
                create_note (false);
                //update_saved_notes();
            });

            note_win.remove_note.connect ((note) => {
                remove_note (note);
                note.destroy();
                update_saved_notes();
            });
        }
        
        public void update_saved_notes () {
            //notes_settings.update_enabled (existing_notes);
            notes_settings.enabled_notes = existing_notes.to_array ();
        }

        public void remove_note(PinnyWindow note) {
            note.note.delete_note (); 
            existing_notes.remove (note.note.id.to_string());
            open_windows.remove (note);
	    }

        public static int main (string[] args) {
            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.textdomain (Build.GETTEXT_PACKAGE);

            var app = new Application();
            return app.run(args);
        }
    }
}