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
    
    public class Backend.Note : Object {
        public int id { get; construct;  }
        public string title { get; set; }
        public string content { get; set; }
        public string colour { get; set; }
        public int32 x { get; set; }
        public int32 y { get; set; }
        public int32 width { get; set; }
        public int32 height { get; set; }

        public signal void content_changed ();

        public NoteSettings note_settings;
        public PinnyWindow note_window;

        public Note (int id) {
            Object(id: id);
            note_settings = new Backend.NoteSettings (id);

            set_defaults ();
        }

        private void set_defaults () {
            title = note_settings.title;
            content = note_settings.content;
            colour = note_settings.colour;

            x = (int32) note_settings.x;
            y = (int32) note_settings.y;
            width = note_settings.width;
            height = note_settings.height;
        }

        public string get_note_content () {
            return note_settings.content;
        }

        public void save_note (string text) {
            content = text;
            //note_storage.save_note (text);
            note_settings.content = text;
        }

        public void set_header_title (string text) {
            title = text;
            note_settings.title = text;
        }

        public void set_position (int32 x, int32 y) {
            this.x = x;
            this.y = y;

            note_settings.x = x;
            note_settings.y = y;
        }

        public void set_size (int width, int height) {
            this.width = width;
            this.height = height;

            note_settings.width = width;
            note_settings.height = height;
        }

        public void delete_note () {
            //note_storage.remove_file ();            
        }

        public void change_colour (string colour) {
            note_settings.colour = colour;
        }

    }
    
}