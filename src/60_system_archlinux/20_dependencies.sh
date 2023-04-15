# Arch Linux - Set list of generic dependencies (32-bit)
# USAGE: pkg_set_deps_arch32 $dep[…]
pkg_set_deps_arch32() {
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep='
				lib32-alsa-lib
				lib32-alsa-plugins'
			;;
			('dosbox')
				pkg_dep='dosbox'
			;;
			('freetype')
				pkg_dep='lib32-freetype2'
			;;
			('gcc32')
				pkg_dep='
				gcc-multilib
				lib32-gcc-libs'
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
			('residualvm')
				pkg_dep='residualvm'
			;;
			('scummvm')
				pkg_dep='scummvm'
			;;
			('sdl2')
				pkg_dep='lib32-sdl2'
			;;
			('wine'|'wine32'|'wine64')
				pkg_dep='wine'
			;;
			('winetricks')
				pkg_dep='
				winetricks
				xterm'
			;;
			('xcursor')
				pkg_dep='lib32-libxcursor'
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
		if variable_is_empty 'pkg_deps'; then
			pkg_deps="$pkg_dep"
		else
			pkg_deps="$pkg_deps $pkg_dep"
		fi
	done
}

# Arch Linux - Set list of generic dependencies (64-bit)
# set list or Arch Linux 64-bit dependencies from generic names
# USAGE: pkg_set_deps_arch64 $dep[…]
pkg_set_deps_arch64() {
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep='
				alsa-lib
				alsa-plugins'
			;;
			('dosbox')
				pkg_dep='dosbox'
			;;
			('freetype')
				pkg_dep='freetype2'
			;;
			('gcc32')
				pkg_dep='
				gcc-multilib
				lib32-gcc-libs'
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
			('residualvm')
				pkg_dep='residualvm'
			;;
			('scummvm')
				pkg_dep='scummvm'
			;;
			('sdl2')
				pkg_dep='sdl2'
			;;
			('wine'|'wine32'|'wine64')
				pkg_dep='wine'
			;;
			('winetricks')
				pkg_dep='
				winetricks
				xterm'
			;;
			('xcursor')
				pkg_dep='libxcursor'
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
		if variable_is_empty 'pkg_deps'; then
			pkg_deps="$pkg_dep"
		else
			pkg_deps="$pkg_deps $pkg_dep"
		fi
	done
}

# Arch Linux - List all dependencies for the given package
# USAGE: dependencies_archlinux_full_list $package
# RETURN: print a list of dependency strings,
#         one per line
dependencies_archlinux_full_list() {
	local package
	package="$1"

	local packages_list packages_list_full
	packages_list_full=''

	# Include generic dependencies
	local package_architecture generic_dependencies_command
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			generic_dependencies_command='pkg_set_deps_arch32'
		;;
		(*)
			generic_dependencies_command='pkg_set_deps_arch64'
		;;
	esac
	local dependencies_generic dependency_generic pkg_deps
	dependencies_generic=$(dependencies_list_generic "$package")
	while read -r dependency_generic; do
		# pkg_set_deps_arch sets a variable $pkg_deps instead of printing a value,
		# we prevent it from leaking by setting it to an empty value.
		pkg_deps=''
		"$generic_dependencies_command" $dependency_generic
		packages_list_full="$packages_list_full
		$pkg_deps"
	done <<- EOL
	$(printf '%s' "$dependencies_generic")
	EOL

	# Include Arch-specific dependencies
	local dependencies_specific
	dependencies_specific=$(context_value "${package}_DEPS_ARCH")
	if [ -n "$dependencies_specific" ]; then
		packages_list=$(printf '%s\n' "$dependencies_specific" | sed 's/ /\n/g')
		packages_list_full="$packages_list_full
		$packages_list"
	fi

	# Include dependencies on native libraries
	packages_list=$(dependencies_list_native_libraries_packages "$package")
	packages_list_full="$packages_list_full
	$packages_list"

	# Include dependencies on Mono libraries
	packages_list=$(dependencies_list_mono_libraries_packages "$package")
	packages_list_full="$packages_list_full
	$packages_list"

	# Include dependencies on GStreamer plugins
	packages_list=$(archlinux_dependencies_gstreamer_all_formats "$package")
	packages_list_full="$packages_list_full
	$packages_list"

	printf '%s' "$packages_list_full" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}
