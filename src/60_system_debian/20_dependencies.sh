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
