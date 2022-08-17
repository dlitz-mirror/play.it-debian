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

	# If the given library is not part of the correspondance table,
	# it is added to the global variable UNKNOWN_LIBRARIES.
	UNKNOWN_LIBRARIES="$UNKNOWN_LIBRARIES
	$library"
	export UNKNOWN_LIBRARIES
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

	# If the given library is not part of the correspondance table,
	# it is added to the global variable UNKNOWN_LIBRARIES.
	UNKNOWN_LIBRARIES="$UNKNOWN_LIBRARIES
	$library"
	export UNKNOWN_LIBRARIES
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
