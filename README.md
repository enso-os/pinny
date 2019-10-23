# Pinny

Easily jot down invaluable thoughts & tasks

![Screenshot](data/screenshot.png?raw=true)

## Installing and Running 

### Dependencies 

	libgtksourceview-3.0-dev 
	libgee-0.8-dev 
	libgtk-3-dev 
	libgranite-dev 
	fonts-firacode 
	valac 
	meson

### Build and install 

Just type from a command line:

	./deps.sh 
	enter sudo password
	mkdir build && meson build --prefix=/usr
    cd build
    ninja
	./pinny
