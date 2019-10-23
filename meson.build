# Name our project
project('pinny', ['vala', 'c'],
    version: '1.0.0'
)

# Import main lib files
gnome = import('gnome')
i18n = import('i18n')

# Set this for convenience
conf = configuration_data()

resources = gnome.compile_resources(
    'as-resources', 'data/pinny.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

# Other configs
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf
add_global_arguments('-DDATADIR="' + get_option('datadir') + '"', language: 'c')
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

# Arguments for C
c_args = [
  '-include', 'config.h', '-w'
]

cc = meson.get_compiler('c')

# Let's define our executable
executable(
    meson.project_name(),
    'src/Application.vala',
    'src/PinnyWindow.vala',
    'src/Widgets/MenuPopover.vala',
    #'src/Backend/Storage.vala',
    'src/Backend/Note.vala',
    'src/Backend/Settings.vala',
    resources,
    c_args: c_args,
    dependencies: [
        dependency('granite'),
        dependency('gobject-2.0'),
        dependency('gtksourceview-3.0'),
        dependency('json-glib-1.0'),
        dependency('gee-0.8'),
        dependency('gtk+-3.0')
    ],
    vala_args: [
        meson.source_root() + '/vapi/config.vapi',
        '--vapidir=' + meson.source_root() + '/vapi/'
    ],
    install : true,
)

# Add in a post install script
meson.add_install_script(meson.source_root() + '/meson/post_install.py')

# Add subfolders for Meson to look
subdir('data')
#subdir('po')