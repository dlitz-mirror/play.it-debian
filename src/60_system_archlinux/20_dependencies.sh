# Arch Linux - Print the package name providing the given native library
# USAGE: dependency_package_providing_library_arch $library
dependency_package_providing_library_arch() {
	local library package_name
	library="$1"
	case "$library" in
		('libasound.so.2')
			package_name='alsa-lib'
		;;
		('libasound_module_'*'.so')
			package_name='alsa-plugins'
		;;
		('libc.so.6')
			package_name='glibc'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='gdk-pixbuf2'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='gtk2'
		;;
		('libGL.so.1')
			package_name='libgl'
		;;
		('libglib-2.0.so.0')
			package_name='glib2'
		;;
		('libGLU.so.1')
			package_name='glu'
		;;
		('libgobject-2.0.so.0')
			package_name='glib2'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='gtk2'
		;;
		('libmbedtls.so.12')
			package_name='mbedtls'
		;;
		('libpng16.so.16')
			package_name='libpng'
		;;
		('libopenal.so.1')
			package_name='openal'
		;;
		('libpulse.so.0')
			package_name='libpulse'
		;;
		('libpulse-simple.so.0')
			package_name='libpulse'
		;;
		('libSDL-1.2.so.0')
			package_name='sdl'
		;;
		('libSDL2-2.0.so.0')
			package_name='sdl2'
		;;
		('libstdc++.so.6')
			package_name='gcc-libs'
		;;
		('libturbojpeg.so.0')
			package_name='libjpeg-turbo'
		;;
		('libudev.so.1')
			package_name='libudev.so=1-64'
		;;
		('libuv.so.1')
			package_name='libuv'
		;;
		('libvorbisfile.so.3')
			package_name='libvorbis'
		;;
		('libX11.so.6')
			package_name='libx11'
		;;
		('libz.so.1')
			package_name='zlib'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	# If the given library is not part of the correspondance table,
	# it is added to the global variable UNKNOWN_LIBRARIES.
	UNKNOWN_LIBRARIES="$UNKNOWN_LIBRARIES
	$library"
	export UNKNOWN_LIBRARIES
}

# Arch Linux - Print the package name providing the given native library in a 32-bit build
# USAGE: dependency_package_providing_library_arch32 $library
dependency_package_providing_library_arch32() {
	local library package_name
	library="$1"
	case "$library" in
		('libasound.so.2')
			package_name='lib32-alsa-lib'
		;;
		('libasound_module_'*'.so')
			package_name='lib32-alsa-plugins'
		;;
		('libc.so.6')
			package_name='lib32-glibc'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='lib32-gdk-pixbuf2'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='lib32-gtk2'
		;;
		('libGL.so.1')
			package_name='lib32-libgl'
		;;
		('libglib-2.0.so.0')
			package_name='lib32-glib2'
		;;
		('libGLU.so.1')
			package_name='lib32-glu'
		;;
		('libgobject-2.0.so.0')
			package_name='lib32-glib2'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='lib32-gtk2'
		;;
		('libmbedtls.so.12')
			# This library is not provided in a 32-bit build for Arch Linux
			unset package_name
		;;
		('libpng16.so.16')
			package_name='lib32-libpng'
		;;
		('libopenal.so.1')
			package_name='lib32-openal'
		;;
		('libpulse.so.0')
			package_name='lib32-libpulse'
		;;
		('libpulse-simple.so.0')
			package_name='lib32-libpulse'
		;;
		('libSDL-1.2.so.0')
			package_name='lib32-sdl'
		;;
		('libSDL2-2.0.so.0')
			package_name='lib32-sdl2'
		;;
		('libstdc++.so.6')
			package_name='lib32-gcc-libs'
		;;
		('libturbojpeg.so.0')
			package_name='lib32-libjpeg-turbo'
		;;
		('libudev.so.1')
			package_name='lib32-systemd'
		;;
		('libuv.so.1')
			# This library is not provided in a 32-bit build for Arch Linux
			unset package_name
		;;
		('libvorbisfile.so.3')
			package_name='lib32-libvorbis'
		;;
		('libX11.so.6')
			package_name='lib32-libx11'
		;;
		('libz.so.1')
			package_name='lib32-zlib'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	# If the given library is not part of the correspondance table,
	# it is added to the global variable UNKNOWN_LIBRARIES.
	UNKNOWN_LIBRARIES="$UNKNOWN_LIBRARIES
	$library"
	export UNKNOWN_LIBRARIES
}
