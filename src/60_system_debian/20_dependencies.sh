# Debian - Set list of generic dependencies
# USAGE: pkg_set_deps_deb $dep[…]
pkg_set_deps_deb() {
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep='libasound2-plugins'
			;;
			('bzip2')
				pkg_dep='libbz2-1.0'
			;;
			('dosbox')
				pkg_dep='dosbox'
			;;
			('freetype')
				pkg_dep='libfreetype6'
			;;
			('gcc32')
				pkg_dep='gcc-multilib:amd64 | gcc'
			;;
			('gconf')
				pkg_dep='libgconf-2-4'
			;;
			('libgdk_pixbuf-2.0.so.0')
				pkg_dep='libgdk-pixbuf-2.0-0 | libgdk-pixbuf2.0-0'
			;;
			('libc.so.6'|'glibc')
				pkg_dep='libc6'
			;;
			('libgobject-2.0.so.0'|'libglib-2.0.so.0')
				pkg_dep='libglib2.0-0'
			;;
			('glu'|'libGLU.so.1')
				pkg_dep='libglu1-mesa | libglu1'
			;;
			('libGL.so.1'|'glx')
				pkg_dep='libgl1 | libgl1-mesa-glx, libglx-mesa0 | libglx-vendor | libgl1-mesa-glx'
			;;
			('libgdk-x11-2.0.so.0'|'libgtk-x11-2.0.so.0'|'gtk2')
				pkg_dep='libgtk2.0-0'
			;;
			('java')
				pkg_dep='default-jre:amd64 | java-runtime:amd64 | default-jre | java-runtime'
			;;
			('json')
				pkg_dep='libjson-c3 | libjson-c2 | libjson0'
			;;
			('libasound.so.2')
				pkg_dep='libasound2'
			;;
			('libasound_module_'*'.so')
				pkg_dep='libasound2-plugins'
			;;
			('libcurl')
				pkg_dep='libcurl4 | libcurl3'
			;;
			('libcurl-gnutls')
				pkg_dep='libcurl3-gnutls'
			;;
			('libmbedtls.so.12')
				pkg_dep='libmbedtls12'
			;;
			('libpng16.so.16')
				pkg_dep='libpng16-16'
			;;
			('libpulse.so.0'|'libpulse-simple.so.0')
				pkg_dep='libpulse0'
			;;
			('libstdc++.so.6'|'libstdc++')
				pkg_dep='libstdc++6'
			;;
			('libudev1'|'libudev.so.1')
				pkg_dep='libudev1'
			;;
			('libX11.so.6')
				pkg_dep='libx11-6'
			;;
			('libxrandr')
				pkg_dep='libxrandr2'
			;;
			('mono')
				pkg_dep='mono-runtime'
			;;
			('nss')
				pkg_dep='libnss3'
			;;
			('openal'|'libopenal.so.1')
				pkg_dep='libopenal1'
			;;
			('pulseaudio')
				pkg_dep='pulseaudio:amd64 | pulseaudio'
			;;
			('renpy')
				pkg_dep='renpy'
			;;
			('sdl1.2'|'libSDL-1.2.so.0')
				pkg_dep='libsdl1.2debian'
			;;
			('sdl2'|'libSDL2-2.0.so.0')
				pkg_dep='libsdl2-2.0-0'
			;;
			('sdl2_image')
				pkg_dep='libsdl2-image-2.0-0'
			;;
			('sdl2_mixer')
				pkg_dep='libsdl2-mixer-2.0-0'
			;;
			('theora')
				pkg_dep='libtheora0'
			;;
			('libturbojpeg.so.0')
				pkg_dep='libturbojpeg0'
			;;
			('libuv.so.1')
				pkg_dep='libuv1'
			;;
			('vorbis'|'libvorbisfile.so.3')
				pkg_dep='libvorbisfile3'
			;;
			('wine'|'wine-staging')
				###
				# TODO
				# $pkg should be computed here, not implicitely inherited from the calling function
				###
				local package_architecture
				package_architecture=$(package_get_architecture "$pkg")
				case "$package_architecture" in
					('32')
						pkg_dep='wine32 | wine32-development | wine-stable-i386 | wine-devel-i386 | wine-staging-i386, wine:amd64 | wine'
					;;
					('64')
						pkg_dep='wine64 | wine64-development | wine-stable-amd64 | wine-devel-amd64 | wine-staging-amd64, wine'
					;;
				esac
			;;
			('winetricks')
				pkg_dep='winetricks, xterm:amd64 | xterm | zenity:amd64 | zenity | kdialog:amd64 | kdialog'
			;;
			('xcursor')
				pkg_dep='libxcursor1'
			;;
			('xft')
				pkg_dep='libxft2'
			;;
			('xgamma'|'xrandr')
				pkg_dep='x11-xserver-utils:amd64 | x11-xserver-utils'
			;;
			('libz.so.1')
				pkg_dep='zlib1g'
			;;
			(*)
				pkg_dep="$dep"
			;;
		esac
		if [ -n "$pkg_deps" ]; then
			pkg_deps="$pkg_deps, $pkg_dep"
		else
			pkg_deps="$pkg_dep"
		fi
	done
}

# Debian - Print the package name providing the given native library
# USAGE: dependency_package_providing_library_deb $library
dependency_package_providing_library_deb() {
	local library package_name
	library="$1"
	case "$library" in
		('libasound.so.2')
			package_name='libasound2'
		;;
		('libasound_module_'*'.so')
			package_name='libasound2-plugins'
		;;
		('libc.so.6')
			package_name='libc6'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='libgdk-pixbuf-2.0-0 | libgdk-pixbuf2.0-0'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='libgtk2.0-0'
		;;
		('libGL.so.1')
			package_name='libgl1 | libgl1-mesa-glx, libglx-mesa0 | libglx-vendor | libgl1-mesa-glx'
		;;
		('libglib-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libGLU.so.1')
			package_name='libglu1-mesa | libglu1'
		;;
		('libgobject-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='libgtk2.0-0'
		;;
		('libmbedtls.so.12')
			package_name='libmbedtls12'
		;;
		('libpng16.so.16')
			package_name='libpng16-16'
		;;
		('libopenal.so.1')
			package_name='libopenal1'
		;;
		('libpulse.so.0')
			package_name='libpulse0'
		;;
		('libpulse-simple.so.0')
			package_name='libpulse0'
		;;
		('libSDL-1.2.so.0')
			package_name='libsdl1.2debian'
		;;
		('libSDL2-2.0.so.0')
			package_name='libsdl2-2.0-0'
		;;
		('libstdc++.so.6')
			package_name='libstdc++6'
		;;
		('libturbojpeg.so.0')
			package_name='libturbojpeg0'
		;;
		('libudev.so.1')
			package_name='libudev1'
		;;
		('libuv.so.1')
			package_name='libuv1'
		;;
		('libvorbisfile.so.3')
			package_name='libvorbisfile3'
		;;
		('libX11.so.6')
			package_name='libx11-6'
		;;
		('libz.so.1')
			package_name='zlib1g'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	dependencies_unknown_libraries_add "$library"
}

# Debian - List all dependencies for the given package
# USAGE: dependencies_debian_full_list $package
# RETURN: print a list of dependency strings,
#         one per line
dependencies_debian_full_list() {
	local package
	package="$1"

	{
		# Include generic dependencies
		local dependencies_generic dependency_generic
		dependencies_generic=$(get_context_specific_value 'archive' "${package}_DEPS")
		for dependency_generic in $dependencies_generic; do
			# pkg_set_deps_deb sets a variable $pkg_deps instead of printing a value,
			# we prevent it from leaking using unset.
			unset pkg_deps
			pkg_set_deps_deb $dependency_generic
			printf '%s\n' "$pkg_deps"
			unset pkg_deps
		done

		# Include Debian-specific dependencies
		local dependencies_specific
		dependencies_specific=$(get_context_specific_value 'archive' "${package}_DEPS_DEB")
		if [ -n "$dependencies_specific" ]; then
			printf '%s' "$dependencies_specific" | sed 's/,/\n/g'
		fi

		# Include dependencies on native libraries
		dependencies_list_native_libraries_packages "$package"
	} | sort --unique
}
