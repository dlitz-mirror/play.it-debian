# Gentoo - Set list of generic dependencies
# USAGE: pkg_set_deps_gentoo $dep[…]
pkg_set_deps_gentoo() {
	local package_architecture architecture_suffix architecture_suffix_use
	package_architecture=$(package_get_architecture "$pkg")
	case "$package_architecture" in
		('32')
			architecture_suffix='[abi_x86_32]'
			architecture_suffix_use=',abi_x86_32'
		;;
		('64')
			architecture_suffix=''
			architecture_suffix_use=''
		;;
	esac
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep="media-libs/alsa-lib$architecture_suffix media-plugins/alsa-plugins$architecture_suffix"
			;;
			('bzip2')
				pkg_dep="app-arch/bzip2$architecture_suffix"
			;;
			('dosbox')
				pkg_dep="games-emulation/dosbox"
			;;
			('freetype')
				pkg_dep="media-libs/freetype$architecture_suffix"
			;;
			('gcc32')
				pkg_dep='' #gcc (in @system) should be multilib unless it is a no-multilib profile, in which case the 32 bits libraries wouldn't work
			;;
			('gconf')
				pkg_dep="gnome-base/gconf$architecture_suffix"
			;;
			('glibc')
				pkg_dep="sys-libs/glibc"
				if [ "$(package_get_architecture "$pkg")" = '32' ]; then
					pkg_dep="$pkg_dep amd64? ( sys-libs/glibc[multilib] )"
				fi
			;;
			('glu')
				pkg_dep="virtual/glu$architecture_suffix"
			;;
			('glx')
				pkg_dep="virtual/opengl$architecture_suffix"
			;;
			('gtk2')
				pkg_dep="x11-libs/gtk+:2$architecture_suffix"
			;;
			('java')
				pkg_dep='virtual/jre'
			;;
			('json')
				pkg_dep="dev-libs/json-c$architecture_suffix"
			;;
			('libcurl')
				pkg_dep="net-misc/curl$architecture_suffix"
			;;
			('libcurl-gnutls')
				pkg_dep="net-libs/libcurl-debian$architecture_suffix"
				pkg_overlay='steam-overlay'
			;;
			('libstdc++')
				pkg_dep='' #maybe this should be virtual/libstdc++, otherwise, it is included in gcc, which should be in @system
			;;
			('libudev1')
				pkg_dep="virtual/libudev$architecture_suffix"
			;;
			('libxrandr')
				pkg_dep="x11-libs/libXrandr$architecture_suffix"
			;;
			('mono')
				pkg_dep="dev-lang/mono$architecture_suffix"
			;;
			('nss')
				pkg_dep="dev-libs/nss$architecture_suffix"
			;;
			('openal')
				pkg_dep="media-libs/openal$architecture_suffix"
			;;
			('pulseaudio')
				pkg_dep='media-sound/pulseaudio'
			;;
			('renpy')
				pkg_dep='games-engines/renpy'
			;;
			('sdl1.2')
				pkg_dep="media-libs/libsdl$architecture_suffix"
			;;
			('sdl2')
				pkg_dep="media-libs/libsdl2$architecture_suffix"
			;;
			('sdl2_image')
				# Most games will require at least jpeg and png
				# Maybe we should add gif and tiff to that list?
				pkg_dep="media-libs/sdl2-image[jpeg,png$architecture_suffix_use]"
			;;
			('sdl2_mixer')
				#Most games will require at least one of flac, mp3, vorbis or wav USE flags, it should better to require them all instead of not requiring any and having non-fonctionnal sound in some games.
				pkg_dep="media-libs/sdl2-mixer[flac,mp3,vorbis,wav$architecture_suffix_use]"
			;;
			('theora')
				pkg_dep="media-libs/libtheora$architecture_suffix"
			;;
			('vorbis')
				pkg_dep="media-libs/libvorbis$architecture_suffix"
			;;
			('wine')
				case "$(package_get_architecture "$pkg")" in
					('32') pkg_set_deps_gentoo 'wine32' ;;
					('64') pkg_set_deps_gentoo 'wine64' ;;
				esac
			;;
			('wine32')
				pkg_dep='virtual/wine[abi_x86_32]'
			;;
			('wine64')
				pkg_dep='virtual/wine[abi_x86_64]'
			;;
			('wine-staging')
				case "$(package_get_architecture "$pkg")" in
					('32') pkg_set_deps_gentoo 'wine32-staging' ;;
					('64') pkg_set_deps_gentoo 'wine64-staging' ;;
				esac
			;;
			('wine32-staging')
				pkg_dep='virtual/wine[staging,abi_x86_32]'
			;;
			('wine64-staging')
				pkg_dep='virtual/wine[staging,abi_x86_64]'
			;;
			('winetricks')
				pkg_dep='app-emulation/winetricks
				|| (
					x11-terms/xterm
					gnome-extra/zenity
					kde-apps/kdialog
				)'
			;;
			('xcursor')
				pkg_dep="x11-libs/libXcursor$architecture_suffix"
			;;
			('xft')
				pkg_dep="x11-libs/libXft$architecture_suffix"
			;;
			('xgamma')
				pkg_dep='x11-apps/xgamma'
			;;
			('xrandr')
				pkg_dep='x11-apps/xrandr'
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
				case "$package_architecture" in
					('32')
						pkg_dep=$(dependency_package_providing_library_gentoo32 "$dep")
					;;
					(*)
						pkg_dep=$(dependency_package_providing_library_gentoo "$dep")
					;;
				esac
			;;
			(*)
				pkg_dep="games-playit/$(printf '%s' "$dep" | sed 's/-/_/g')"
				local package packages_list
				packages_list=$(packages_get_list)
				for package in $packages_list; do
					if [ "$package" != "$pkg" ]; then
						if [ "$(package_get_provide "$package")" = "$(printf '%s' "!!games-playit/${dep}" | sed 's/-/_/g')" ]; then
							pkg_dep="|| ( ${pkg_dep} )"
						fi
					fi
				done
			;;
		esac
		if [ -n "$pkg_dep" ]; then
			pkg_deps="$pkg_deps $pkg_dep"
		fi
		if [ -n "$pkg_overlay" ]; then
			if ! printf '%s' "$GENTOO_OVERLAYS" | sed --regexp-extended 's/\s+/\n/g' | grep --fixed-strings --line-regexp --quiet "$pkg_overlay"; then
				GENTOO_OVERLAYS="$GENTOO_OVERLAYS $pkg_overlay"
			fi
			pkg_overlay=''
		fi
	done
}

# Gentoo - Print the package name providing the given native library
# USAGE: dependency_package_providing_library_gentoo $library
dependency_package_providing_library_gentoo() {
	local library package_name
	library="$1"
	case "$library" in
		('libasound.so.2')
			package_name='media-libs/alsa-lib'
		;;
		('libasound_module_'*'.so')
			package_name='media-plugins/alsa-plugins'
		;;
		('libc.so.6')
			package_name='sys-libs/glibc'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='x11-libs/gdk-pixbuf:2'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='x11-libs/gtk+:2'
		;;
		('libGL.so.1')
			package_name='virtual/opengl'
		;;
		('libglib-2.0.so.0')
			package_name='dev-libs/glib:2'
		;;
		('libGLU.so.1')
			package_name='virtual/glu'
		;;
		('libgobject-2.0.so.0')
			package_name='dev-libs/glib:2'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='x11-libs/gtk+:2'
		;;
		('libmbedtls.so.12')
			package_name='net-libs/mbedtls:0/12'
		;;
		('libpng16.so.16')
			package_name='media-libs/libpng:0/16'
		;;
		('libopenal.so.1')
			package_name='media-libs/openal'
		;;
		('libpulse.so.0')
			package_name='media-sound/pulseaudio'
		;;
		('libpulse-simple.so.0')
			package_name='media-sound/pulseaudio'
		;;
		('libSDL-1.2.so.0')
			package_name='media-libs/libsdl'
		;;
		('libSDL2-2.0.so.0')
			package_name='media-libs/libsdl2'
		;;
		('libstdc++.so.6')
			package_name='virtual/libstdc++'
		;;
		('libturbojpeg.so.0')
			package_name='media-libs/libjpeg-turbo'
		;;
		('libudev.so.1')
			package_name='virtual/libudev'
		;;
		('libuv.so.1')
			package_name='dev-libs/libuv:0/1'
		;;
		('libvorbisfile.so.3')
			package_name='media-libs/libvorbis'
		;;
		('libX11.so.6')
			package_name='x11-libs/libX11'
		;;
		('libz.so.1')
			package_name='sys-libs/zlib:0/1'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	dependencies_unknown_libraries_add "$library"
}

# Gentoo - Print the package name providing the given native library in a 32-bit build
# USAGE: dependency_package_providing_library_gentoo32 $library
dependency_package_providing_library_gentoo32() {
	local library package_name
	library="$1"
	case "$library" in
		('libasound.so.2')
			package_name='media-libs/alsa-lib[abi_x86_32]'
		;;
		('libasound_module_'*'.so')
			package_name='media-plugins/alsa-plugins[abi_x86_32]'
		;;
		('libc.so.6')
			package_name='sys-libs/glibc amd64? ( sys-libs/glibc[multilib] )'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='x11-libs/gdk-pixbuf:2[abi_x86_32]'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='x11-libs/gtk+:2[abi_x86_32]'
		;;
		('libGL.so.1')
			package_name='virtual/opengl[abi_x86_32]'
		;;
		('libglib-2.0.so.0')
			package_name='dev-libs/glib:2[abi_x86_32]'
		;;
		('libGLU.so.1')
			package_name='virtual/glu[abi_x86_32]'
		;;
		('libgobject-2.0.so.0')
			package_name='dev-libs/glib:2[abi_x86_32]'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='x11-libs/gtk+:2[abi_x86_32]'
		;;
		('libmbedtls.so.12')
			package_name='net-libs/mbedtls:0/12[abi_x86_32]'
		;;
		('libpng16.so.16')
			package_name='media-libs/libpng:0/16[abi_x86_32]'
		;;
		('libopenal.so.1')
			package_name='media-libs/openal[abi_x86_32]'
		;;
		('libpulse.so.0')
			package_name='media-sound/pulseaudio[abi_x86_32]'
		;;
		('libpulse-simple.so.0')
			package_name='media-sound/pulseaudio[abi_x86_32]'
		;;
		('libSDL-1.2.so.0')
			package_name='media-libs/libsdl[abi_x86_32]'
		;;
		('libSDL2-2.0.so.0')
			package_name='media-libs/libsdl2[abi_x86_32]'
		;;
		('libstdc++.so.6')
			package_name='virtual/libstdc++[abi_x86_32]'
		;;
		('libturbojpeg.so.0')
			package_name='media-libs/libjpeg-turbo[abi_x86_32]'
		;;
		('libudev.so.1')
			package_name='virtual/libudev[abi_x86_32]'
		;;
		('libuv.so.1')
			package_name='dev-libs/libuv:0/1[abi_x86_32]'
		;;
		('libvorbisfile.so.3')
			package_name='media-libs/libvorbis[abi_x86_32]'
		;;
		('libX11.so.6')
			package_name='x11-libs/libX11[abi_x86_32]'
		;;
		('libz.so.1')
			package_name='sys-libs/zlib:0/1[abi_x86_32]'
		;;
	esac

	if [ -n "$package_name" ]; then
		printf '%s' "$package_name"
		return 0
	fi

	dependencies_unknown_libraries_add "$library"
}

# Gentoo - List all dependencies for the given package
# USAGE: dependencies_gentoo_full_list $package
dependencies_gentoo_full_list() {
	local package
	package="$1"

	{
		# Include generic dependencies
		local dependencies_generic dependency_generic
		dependencies_generic=$(get_context_specific_value 'archive' "${package}_DEPS")
		for dependency_generic in $dependencies_generic; do
			# pkg_set_deps_gentoo sets a variable $pkg_deps instead of printing a value,
			# we prevent it from leaking using unset.
			unset pkg_deps
			pkg_set_deps_gentoo $dependencies_generic
			printf '%s\n' "$pkg_deps"
			unset pkg_deps
		done

		# Include Gentoo-specific dependencies
		local dependencies_specific
		dependencies_specific=$(get_context_specific_value 'archive' "${package}_DEPS_GENTOO")
		if [ -n "$dependencies_specific" ]; then
			printf '%s\n' "$dependencies_specific" | sed 's/ /\n/g'
		fi

		# Include dependencies on native libraries
		dependencies_list_native_libraries_packages "$package"

		local package_provide
		package_provide=$(package_get_provide "$package")
		if [ -n "$package_provide" ]; then
			printf '%s\n' "$package_provide"
		fi
	} | sort --unique
}
