# Gentoo - Set list of generic dependencies
# USAGE: pkg_set_deps_gentoo $package $dep[…]
pkg_set_deps_gentoo() {
	local package
	package="$1"
	shift

	local package_architecture architecture_suffix
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			architecture_suffix='[abi_x86_32]'
		;;
		('64')
			architecture_suffix=''
		;;
	esac
	local pkg_dep
	for dep in "$@"; do
		pkg_dep=''
		case $dep in
			('alsa')
				pkg_dep="media-libs/alsa-lib$architecture_suffix media-plugins/alsa-plugins$architecture_suffix"
			;;
			('freetype')
				pkg_dep="media-libs/freetype$architecture_suffix"
			;;
			('gcc32')
				pkg_dep='' #gcc (in @system) should be multilib unless it is a no-multilib profile, in which case the 32 bits libraries wouldn't work
			;;
			('glibc')
				pkg_dep="sys-libs/glibc"
				if [ "$package_architecture" = '32' ]; then
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
			('json')
				pkg_dep="dev-libs/json-c$architecture_suffix"
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
			('nss')
				pkg_dep="dev-libs/nss$architecture_suffix"
			;;
			('openal')
				pkg_dep="media-libs/openal$architecture_suffix"
			;;
			('sdl2')
				pkg_dep="media-libs/libsdl2$architecture_suffix"
			;;
			('xcursor')
				pkg_dep="x11-libs/libXcursor$architecture_suffix"
			;;
			( \
				'dosbox' | \
				'java' | \
				'mono' | \
				'pulseaudio' | \
				'scummvm' | \
				'wine' | \
				'winetricks' | \
				'xgamma' | \
				'xrandr' \
			)
				gentoo_dependencies_single_command "$package" "$dependency_keyword"
			;;
			( \
				'libasound.so.2' | \
				'libasound_module_'*'.so' | \
				'libc.so.6' | \
				'libgdk_pixbuf-2.0.so.0' | \
				'libgdk-x11-2.0.so.0' | \
				'libGL.so.1' | \
				'libglib-2.0.so.0' | \
				'libGLU.so.1' | \
				'libgobject-2.0.so.0' | \
				'libgtk-x11-2.0.so.0' | \
				'libmbedtls.so.12' | \
				'libpng16.so.16' | \
				'libpulse.so.0' | \
				'libpulse-simple.so.0' | \
				'libopenal.so.1' | \
				'libSDL-1.2.so.0' | \
				'libSDL2-2.0.so.0' | \
				'libstdc++.so.6' | \
				'libturbojpeg.so.0' | \
				'libuv.so.1' | \
				'libudev.so.1' | \
				'libvorbisfile.so.3' | \
				'libX11.so.6' | \
				'libz.so.1' \
			)
				case "$package_architecture" in
					('32')
						pkg_dep=$(dependency_package_providing_library_gentoo32 "$dep" "$package")
					;;
					(*)
						pkg_dep=$(dependency_package_providing_library_gentoo "$dep" "$package")
					;;
				esac
			;;
		esac
		if [ -n "$pkg_dep" ]; then
			if variable_is_empty 'pkg_deps'; then
				pkg_deps="$pkg_dep"
			else
				pkg_deps="$pkg_deps $pkg_dep"
			fi
		fi
	done
}

# Gentoo - List all dependencies for the given package
# USAGE: dependencies_gentoo_full_list $package
dependencies_gentoo_full_list() {
	local package
	package="$1"

	# Include generic dependencies
	local dependencies_generic dependency_generic
	dependencies_generic=$(dependencies_list_generic "$package")
	while read -r dependency_generic; do
		# pkg_set_deps_gentoo sets a variable $pkg_deps instead of printing a value,
		# we prevent it from leaking by setting it to an empty value.
		pkg_deps=''
		pkg_set_deps_gentoo $package $dependency_generic
		printf '%s\n' "$pkg_deps"
	done <<- EOL
	$(printf '%s' "$dependencies_generic")
	EOL

	# Include Gentoo-specific dependencies
	local dependencies_specific
	dependencies_specific=$(context_value "${package}_DEPS_GENTOO")
	if [ -n "$dependencies_specific" ]; then
		printf '%s\n' "$dependencies_specific"
	fi

	local packages_list packages_list_full
	packages_list_full=''

	# Include dependencies on commands
	packages_list=$(gentoo_dependencies_all_commands "$package")
	packages_list_full="$packages_list_full
	$packages_list"

	# Include dependencies on native libraries
	packages_list=$(dependencies_list_native_libraries_packages "$package")
	packages_list_full="$packages_list_full
	$packages_list"

	# Include dependencies on Mono libraries
	packages_list=$(dependencies_list_mono_libraries_packages "$package")
	packages_list_full="$packages_list_full
	$packages_list"

	# Include dependencies on GStreamer plugins
	packages_list=$(gentoo_dependencies_gstreamer_all_formats "$package")
	packages_list_full="$packages_list_full
	$packages_list"

	printf '%s' "$packages_list_full" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Gentoo - Print the path to a temporary file used for additional overlays listing
# USAGE: dependency_gentoo_overlays_file
dependency_gentoo_overlays_file() {
	printf '%s/overlays' "$PLAYIT_WORKDIR"
}

# Gentoo - Add an overlay to the list of additional overlays
# USAGE: dependency_gentoo_overlays_add $overlay
dependency_gentoo_overlays_add() {
	local overlay overlays_file
	overlay="$1"
	overlays_file="$(dependency_gentoo_overlays_file)"

	# Do nothing if this overlay is already included in the list
	if test -e "$overlays_file" \
		&& grep --quiet --fixed-strings --word-regexp "$overlay" < "$overlays_file"
	then
		return 0
	fi

	printf '%s\n' "$overlay" >> "$overlays_file"
}

# Gentoo - Print gentoo libdir name
# USAGE: dependency_gentoo_libdir $arch_string
# Note: This prints the name (ie. “lib”) not the path (ie. “/usr/lib”)
dependency_gentoo_libdir() {
	local arch_string="$1"
	if command -v portageq >/dev/null 2>&1; then
		print '%s' "$(portageq envvar "LIBDIR_${arch_string}")"
	else
		case "$arch_string" in
			('amd64')
				printf '%s' 'lib64'
				;;
			('x86')
				printf '%s' 'lib'
				;;
			('x32')
				printf '%s' 'libx32'
				;;
			(*)
				error_unknown_gentoo_architecture_string "$arch_string" 'dependency_gentoo_libdir'
				return 1
				;;
		esac
	fi
	return 0
}

# Gentoo - Link library installed in non-standard libdir to the game’s libdir
# USAGE: dependencies_gentoo_link $libname $libdir $package
# Note: $libdir is the library’s directory, not the game’s one!
dependencies_gentoo_link() {
	local libname libdir package game_libdir
	libname="$1"
	libdir="$2"
	package="$3"
	game_libdir="$(path_libraries)"

	local package_path library_destination
	package_path=$(package_path "$package")
	library_destination="${package_path}${game_libdir}"

	mkdir --parents "$library_destination"
	ln -sft "$library_destination" "${libdir}/${libname}"
}
