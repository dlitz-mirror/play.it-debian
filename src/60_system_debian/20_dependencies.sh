# Print the list of packages required to provide the given generic dependency keyword on Debian
# USAGE: pkg_set_deps_deb $dependency_keyword [$package]
pkg_set_deps_deb() {
	# The optional second argument is only used with the "wine" dependency keyword.
	local dependency_keyword package
	dependency_keyword="$1"
	package="$2"

	case "$dependency_keyword" in
		('alsa')
			printf 'libasound2-plugins'
		;;
		('dosbox')
			printf 'dosbox'
		;;
		('freetype')
			printf 'libfreetype6'
		;;
		('gcc32')
			printf 'gcc-multilib:amd64 | gcc'
		;;
		('glibc')
			printf 'libc6'
		;;
		('glu')
			printf 'libglu1-mesa | libglu1'
		;;
		('glx')
			printf 'libgl1 | libgl1-mesa-glx, libglx-mesa0 | libglx-vendor | libgl1-mesa-glx'
		;;
		('gtk2')
			printf 'libgtk2.0-0'
		;;
		('java')
			printf 'default-jre:amd64 | java-runtime:amd64 | default-jre | java-runtime'
		;;
		('json')
			printf 'libjson-c3 | libjson-c2 | libjson0'
		;;
		('libstdc++')
			printf 'libstdc++6'
		;;
		('libudev1')
			printf 'libudev1'
		;;
		('libxrandr')
			printf 'libxrandr2'
		;;
		('mono')
			printf 'mono-runtime'
		;;
		('nss')
			printf 'libnss3'
		;;
		('openal')
			printf 'libopenal1'
		;;
		('pulseaudio')
			printf 'pulseaudio:amd64 | pulseaudio'
		;;
		('renpy')
			printf 'renpy'
		;;
		('residualvm')
			printf 'residualvm'
		;;
		('scummvm')
			printf 'scummvm'
		;;
		('sdl2')
			printf 'libsdl2-2.0-0'
		;;
		('wine')
			local package package_architecture
			package_architecture=$(package_architecture "$package")
			case "$package_architecture" in
				('32')
					printf 'wine32 | wine32-development | wine-stable-i386 | wine-devel-i386 | wine-staging-i386, wine:amd64 | wine'
				;;
				('64')
					printf 'wine64 | wine64-development | wine-stable-amd64 | wine-devel-amd64 | wine-staging-amd64, wine'
				;;
			esac
		;;
		('winetricks')
			printf 'winetricks, xterm:amd64 | xterm | zenity:amd64 | zenity | kdialog:amd64 | kdialog'
		;;
		('xcursor')
			printf 'libxcursor1'
		;;
		('xgamma'|'xrandr')
			printf 'x11-xserver-utils:amd64 | x11-xserver-utils'
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
			dependency_package_providing_library_deb "$dependency_keyword"
		;;
		(*)
			# Unknown dependency keywords are assumed to be litteral package names.
			printf '%s' "$dependency_keyword"
		;;
	esac
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
	local dependency_generic dependency_package
	while read -r dependency_generic; do
		dependency_package=$(pkg_set_deps_deb "$dependency_generic" "$package")
		packages_list_full="$packages_list_full
		$dependency_package"
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
