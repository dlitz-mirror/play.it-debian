# Debian - Set list of generic dependencies
# USAGE: pkg_set_deps_deb $dep[…]
pkg_set_deps_deb() {
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep='libasound2-plugins'
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
			('glibc')
				pkg_dep='libc6'
			;;
			('glu')
				pkg_dep='libglu1-mesa | libglu1'
			;;
			('glx')
				pkg_dep='libgl1 | libgl1-mesa-glx, libglx-mesa0 | libglx-vendor | libgl1-mesa-glx'
			;;
			('gtk2')
				pkg_dep='libgtk2.0-0'
			;;
			('java')
				pkg_dep='default-jre:amd64 | java-runtime:amd64 | default-jre | java-runtime'
			;;
			('json')
				pkg_dep='libjson-c3 | libjson-c2 | libjson0'
			;;
			('libstdc++')
				pkg_dep='libstdc++6'
			;;
			('libudev1')
				pkg_dep='libudev1'
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
			('openal')
				pkg_dep='libopenal1'
			;;
			('pulseaudio')
				pkg_dep='pulseaudio:amd64 | pulseaudio'
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
				pkg_dep='libsdl2-2.0-0'
			;;
			('wine')
				# FIXME - $package should be passed as a function argument, not inherited from the calling function
				local package
				package="$pkg"

				local package_architecture
				package_architecture=$(package_architecture "$package")
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
			('xgamma'|'xrandr')
				pkg_dep='x11-xserver-utils:amd64 | x11-xserver-utils'
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
				pkg_dep=$(dependency_package_providing_library_deb "$dep")
			;;
			(*)
				pkg_dep="$dep"
			;;
		esac
		if variable_is_empty 'pkg_deps'; then
			pkg_deps="$pkg_dep"
		else
			pkg_deps="$pkg_deps, $pkg_dep"
		fi
	done
}

# Debian - List all dependencies for the given package
# USAGE: dependencies_debian_full_list $package
# RETURN: print a list of dependency strings,
#         one per line
dependencies_debian_full_list() {
	local package
	package="$1"

	local packages_list packages_list_full
	packages_list_full=''

	# Include generic dependencies
	local dependency_generic pkg_deps
	while read -r dependency_generic; do
		# pkg_set_deps_deb sets a variable $pkg_deps instead of printing a value,
		# we prevent it from leaking by setting it to an empty value.
		pkg_deps=''
		pkg_set_deps_deb $dependency_generic
		packages_list_full="$packages_list_full
		$pkg_deps"
	done <<- EOL
	$(dependencies_list_generic "$package")
	EOL

	# Include Debian-specific dependencies
	local dependencies_specific
	dependencies_specific=$(context_value "${package}_DEPS_DEB")
	if [ -n "$dependencies_specific" ]; then
		packages_list=$(printf '%s\n' "$dependencies_specific" | sed 's/, \?/\n/g')
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

	printf '%s' "$packages_list_full" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}
