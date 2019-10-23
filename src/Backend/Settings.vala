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

namespace Pinny.Backend {

    public class EnabledNotesSettings : GLib.Object
    {
        public GLib.Settings settings { get; construct; }
        public string[] enabled_notes { get; set; }
        //public Gee.ArrayList<string> enabled_notes = new Gee.ArrayList<string> ();


        public EnabledNotesSettings () { 
            Object ( settings: new GLib.Settings ("org.enso.pinny")); 
            settings.bind("enabled-notes",this,"enabled_notes",SettingsBindFlags.DEFAULT);
        }

    }

    public class NoteSettings : GLib.Object
    {
        public GLib.Settings settings { get; construct; }
        public GLib.SettingsBindFlags bind_flags { get; construct; default = SettingsBindFlags.DEFAULT; }

        public string title { get; set; }
        public string content { get; set; }
        public string colour { get; set; }
        public double x { get; set; }
        public double y { get; set; }
        public int width { get; set; }
        public int height { get; set; }

        public NoteSettings (int id) { 
            Object ( settings: create_settings ("org.enso.pinny.note.settings", "/org/enso/pinny/notes/%d/".printf(id)));
        }

        // code taken from plank settings.vala
        construct
		{
			unowned string class_type_name = get_type ().name ();
			
			debug ("Bind '%s' to '%s'", class_type_name, settings.path);
			
			(unowned ParamSpec)[] properties = get_class ().list_properties ();
			
			// Bind available gsettings-keys to their class-properties
			foreach (unowned string key in settings.list_keys ()) {
				//Not taking a references of matched ParamSpec results in undefined behaviour
				ParamSpec? property = null;
				foreach (unowned ParamSpec p in properties)
					if (p.get_nick () == key) {
						property = p;
						break;
					}
				if (property == null)
					continue;
				
				unowned string name = property.get_name ();
				unowned string nick = property.get_nick ();
				var type = property.value_type;
				
				debug ("Bind '%s%s' to '%s.%s'", settings.path, nick, class_type_name, name);
				if (type.is_fundamental () || type.is_enum () || type.is_flags () || type == typeof(string[])) {
					settings.bind (nick, this, name, bind_flags);
				} else {
					warning ("Binding of '%s' from type '%s' not supported yet!", name, type.name ());
				}
				
				//verify (name);
			}
		}

        /**
         * Creates a new {@link GLib.Settings} object with a given schema and path.
         *
         * It is fatal if no schema to the given schema_id is found!
         *
         * If path is NULL then the path from the schema is used. It is an error if
         * path is NULL and the schema has no path of its own or if path is non-NULL
         * and not equal to the path that the schema does have.
         *
         * @param schema_id a schema ID
         * @param path the path to use
         * @return a new GLib.Settings object
        */
        public static GLib.Settings create_settings (string schema_id, string? path = null)
        {
            //FIXME Only to make it run/work uninstalled from top_builddir
            Environment.set_variable ("GSETTINGS_SCHEMA_DIR", Environment.get_current_dir () + "/data", false);
            
            var schema = GLib.SettingsSchemaSource.get_default ().lookup (schema_id, true);
            if (schema == null)
                error ("GSettingsSchema '%s' not found", schema_id);
            
            var settings = new GLib.Settings.full (schema, null, path);
            if (settings == null)
                error ("GSettings '%s' not correct", path);
        
            return settings;
        }
    }        
}