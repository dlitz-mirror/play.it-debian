# Arch Linux - Set list of generic dependencies
# USAGE: pkg_set_deps_arch $dep[…]
pkg_set_deps_arch() {
	case "$(package_get_architecture "$pkg")" in
		('32')
			pkg_set_deps_arch32 "$@"
		;;
		(*)
			pkg_set_deps_arch64 "$@"
		;;
	esac
}

# Arch Linux - Set list of generic dependencies (32-bit)
# USAGE: pkg_set_deps_arch32 $dep[…]
pkg_set_deps_arch32() {
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep='lib32-alsa-lib lib32-alsa-plugins'
			;;
			('bzip2')
				pkg_dep='lib32-bzip2'
			;;
			('dosbox')
				pkg_dep='dosbox'
			;;
			('freetype')
				pkg_dep='lib32-freetype2'
			;;
			('gcc32')
				pkg_dep='gcc-multilib lib32-gcc-libs'
			;;
			('gconf')
				pkg_dep='lib32-gconf'
			;;
			('glibc')
				pkg_dep='lib32-glibc'
			;;
			('glu')
				pkg_dep='lib32-glu'
			;;
			('glx')
				pkg_dep='lib32-libgl'
			;;
			('gtk2')
				pkg_dep='lib32-gtk2'
			;;
			('java')
				pkg_dep='jre8-openjdk'
			;;
			('json')
				pkg_dep='lib32-json-c'
			;;
			('libcurl')
				pkg_dep='lib32-curl'
			;;
			('libcurl-gnutls')
				pkg_dep='lib32-libcurl-gnutls'
			;;
			('libstdc++')
				pkg_dep='lib32-gcc-libs'
			;;
			('libudev1')
				pkg_dep='lib32-systemd'
			;;
			('libxrandr')
				pkg_dep='lib32-libxrandr'
			;;
			('nss')
				pkg_dep='lib32-nss'
			;;
			('openal')
				pkg_dep='lib32-openal'
			;;
			('pulseaudio')
				pkg_dep='pulseaudio'
			;;
			('renpy')
				pkg_dep='renpy'
			;;
			('sdl1.2')
				pkg_dep='lib32-sdl'
			;;
			('sdl2')
				pkg_dep='lib32-sdl2'
			;;
			('sdl2_image')
				pkg_dep='lib32-sdl2_image'
			;;
			('sdl2_mixer')
				pkg_dep='lib32-sdl2_mixer'
			;;
			('theora')
				pkg_dep='lib32-libtheora'
			;;
			('vorbis')
				pkg_dep='lib32-libvorbis'
			;;
			('wine'|'wine32'|'wine64')
				pkg_dep='wine'
			;;
			('wine-staging'|'wine32-staging'|'wine64-staging')
				pkg_dep='wine-staging'
			;;
			('winetricks')
				pkg_dep='winetricks xterm'
			;;
			('xcursor')
				pkg_dep='lib32-libxcursor'
			;;
			('xft')
				pkg_dep='lib32-libxft'
			;;
			('xgamma')
				pkg_dep='xorg-xgamma'
			;;
			('xrandr')
				pkg_dep='xorg-xrandr'
			;;
			( \
				'libgdk_pixbuf-2.0.so.0' | \
				'libc.so.6' | \
				'libglib-2.0.so.0' | \
				'libgobject-2.0.so.0' | \
				'libGLU.so.1' | \
				'libGL.so.1' | \
				'libgdk-x11-2.0.so.0' | \
				'libgtk-x11-2.0.so.0' | \
				'libasound.so.2' | \
				'libasound_module_'*'.so' | \
				'libmbedtls.so.12' | \
				'libpng16.so.16' | \
				'libpulse.so.0' | \
				'libpulse-simple.so.0' | \
				'libstdc++.so.6' | \
				'libudev.so.1' | \
				'libX11.so.6' | \
				'libopenal.so.1' | \
				'libSDL-1.2.so.0' | \
				'libSDL2-2.0.so.0' | \
				'libturbojpeg.so.0' | \
				'libuv.so.1' | \
				'libvorbisfile.so.3' | \
				'libz.so.1' \
			)
				pkg_dep=$(dependency_package_providing_library_arch32 "$dep")
			;;
			(*)
				pkg_dep="$dep"
			;;
		esac
		pkg_deps="$pkg_deps $pkg_dep"
	done
}

# Arch Linux - Set list of generic dependencies (64-bit)
# set list or Arch Linux 64-bit dependencies from generic names
# USAGE: pkg_set_deps_arch64 $dep[…]
pkg_set_deps_arch64() {
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep='alsa-lib alsa-plugins'
			;;
			('bzip2')
				pkg_dep='bzip2'
			;;
			('dosbox')
				pkg_dep='dosbox'
			;;
			('freetype')
				pkg_dep='freetype2'
			;;
			('gcc32')
				pkg_dep='gcc-multilib lib32-gcc-libs'
			;;
			('gconf')
				pkg_dep='gconf'
			;;
			('glibc')
				pkg_dep='glibc'
			;;
			('glu')
				pkg_dep='glu'
			;;
			('glx')
				pkg_dep='libgl'
			;;
			('gtk2')
				pkg_dep='gtk2'
			;;
			('java')
				pkg_dep='jre8-openjdk'
			;;
			('json')
				pkg_dep='json-c'
			;;
			('libcurl')
				pkg_dep='curl'
			;;
			('libcurl-gnutls')
				pkg_dep='libcurl-gnutls'
			;;
			('libstdc++')
				pkg_dep='gcc-libs'
			;;
			('libudev1')
				pkg_dep='libudev.so=1-64'
			;;
			('libxrandr')
				pkg_dep='libxrandr'
			;;
			('nss')
				pkg_dep='nss'
			;;
			('mono')
				pkg_dep='mono'
			;;
			('openal')
				pkg_dep='openal'
			;;
			('pulseaudio')
				pkg_dep='pulseaudio'
			;;
			('renpy')
				pkg_dep='renpy'
			;;
			('sdl1.2')
				pkg_dep='sdl'
			;;
			('sdl2')
				pkg_dep='sdl2'
			;;
			('sdl2_image')
				pkg_dep='sdl2_image'
			;;
			('sdl2_mixer')
				pkg_dep='sdl2_mixer'
			;;
			('theora')
				pkg_dep='libtheora'
			;;
			('vorbis')
				pkg_dep='libvorbis'
			;;
			('wine'|'wine32'|'wine64')
				pkg_dep='wine'
			;;
			('winetricks')
				pkg_dep='winetricks'
			;;
			('xcursor')
				pkg_dep='libxcursor'
			;;
			('xft')
				pkg_dep='libxft'
			;;
			('xgamma')
				pkg_dep='xorg-xgamma'
			;;
			('xrandr')
				pkg_dep='xorg-xrandr'
			;;
			( \
				'libgdk_pixbuf-2.0.so.0' | \
				'libc.so.6' | \
				'libglib-2.0.so.0' | \
				'libgobject-2.0.so.0' | \
				'libGLU.so.1' | \
				'libGL.so.1' | \
				'libgdk-x11-2.0.so.0' | \
				'libgtk-x11-2.0.so.0' | \
				'libasound.so.2' | \
				'libasound_module_'*'.so' | \
				'libmbedtls.so.12' | \
				'libpng16.so.16' | \
				'libpulse.so.0' | \
				'libpulse-simple.so.0' | \
				'libstdc++.so.6' | \
				'libudev.so.1' | \
				'libX11.so.6' | \
				'libopenal.so.1' | \
				'libSDL-1.2.so.0' | \
				'libSDL2-2.0.so.0' | \
				'libturbojpeg.so.0' | \
				'libuv.so.1' | \
				'libvorbisfile.so.3' | \
				'libz.so.1' \
			)
				pkg_dep=$(dependency_package_providing_library_arch "$dep")
			;;
			(*)
				pkg_dep="$dep"
			;;
		esac
		pkg_deps="$pkg_deps $pkg_dep"
	done
}

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

	dependencies_unknown_libraries_add "$library"
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

	dependencies_unknown_libraries_add "$library"
}

# Arch Linux - List all dependencies for the given package
# USAGE: dependencies_archlinux_full_list $package
# RETURN: print a list of dependency strings,
#         one per line
dependencies_archlinux_full_list() {
	local package
	package="$1"

	{
		# Include generic dependencies
		local dependencies_generic dependency_generic
		dependencies_generic=$(get_context_specific_value 'archive' "${package}_DEPS")
		for dependency_generic in $dependencies_generic; do
			# pkg_set_deps_arch sets a variable $pkg_deps instead of printing a value,
			# we prevent it from leaking using unset.
			unset pkg_deps
			pkg_set_deps_arch $dependencies_generic
			printf '%s\n' "$pkg_deps"
			unset pkg_deps
		done

		# Include Arch-specific dependencies
		local dependencies_specific
		dependencies_specific=$(get_context_specific_value 'archive' "${package}_DEPS_ARCH")
		if [ -n "$dependencies_specific" ]; then
			printf '%s\n' "$dependencies_specific" | sed 's/ /\n/g'
		fi

		# Include dependencies on native libraries
		dependencies_list_native_libraries_packages "$package"
	} | sort --unique
}
