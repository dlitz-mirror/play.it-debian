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
			('libcurl')
				pkg_dep='libcurl4 | libcurl3'
			;;
			('libcurl-gnutls')
				pkg_dep='libcurl3-gnutls'
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
			('sdl1.2')
				pkg_dep='libsdl1.2debian'
			;;
			('sdl2')
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
			('vorbis')
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
		('ld-linux.so.2')
			package_name='libc6'
		;;
		('ld-linux-x86-64.so.2')
			package_name='libc6'
		;;
		('libasound.so.2')
			package_name='libasound2'
		;;
		('libasound_module_'*'.so')
			package_name='libasound2-plugins'
		;;
		('libatk-1.0.so.0')
			package_name='libatk1.0-0'
		;;
		('libavcodec.so.58')
			package_name='libavcodec58 | libavcodec-extra58'
		;;
		('libavformat.so.58')
			package_name='libavformat58 | libavformat-extra58'
		;;
		('libavutil.so.56')
			package_name='libavutil56'
		;;
		('libc.so.6')
			package_name='libc6'
		;;
		('libcairo.so.2')
			package_name='libcairo2'
		;;
		('libcrypto.so.1.1')
			package_name='libssl1.1'
		;;
		('libcurl.so.4')
			package_name='libcurl4'
		;;
		('libdl.so.2')
			package_name='libc6'
		;;
		('libexpat.so.1')
			package_name='libexpat1'
		;;
		('libfontconfig.so.1')
			package_name='libfontconfig1'
		;;
		('libfreeimage.so.3')
			package_name='libfreeimage3'
		;;
		('libfreetype.so.6')
			package_name='libfreetype6'
		;;
		('libgcc_s.so.1')
			package_name='libgcc-s1'
		;;
		('libgdk_pixbuf-2.0.so.0')
			package_name='libgdk-pixbuf-2.0-0 | libgdk-pixbuf2.0-0'
		;;
		('libgdk-x11-2.0.so.0')
			package_name='libgtk2.0-0'
		;;
		('libgio-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libGL.so.1')
			package_name='
			libgl1 | libgl1-mesa-glx
			libglx-mesa0 | libglx-vendor | libgl1-mesa-glx'
		;;
		('libglfw.so.3')
			package_name='libglfw3 | libglfw3-wayland'
		;;
		('libglib-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libGLU.so.1')
			package_name='libglu1-mesa | libglu1'
		;;
		('libgmodule-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libgobject-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libgthread-2.0.so.0')
			package_name='libglib2.0-0'
		;;
		('libgtk-x11-2.0.so.0')
			package_name='libgtk2.0-0'
		;;
		('libICE.so.6')
			package_name='libice6'
		;;
		('libm.so.6')
			package_name='libc6'
		;;
		('libmbedtls.so.12')
			package_name='libmbedtls12'
		;;
		('libminiupnpc.so.17')
			package_name='libminiupnpc17'
		;;
		('libopenal.so.1')
			package_name='libopenal1'
		;;
		('libpango-1.0.so.0')
			package_name='libpango-1.0-0'
		;;
		('libpangocairo-1.0.so.0')
			package_name='libpangocairo-1.0-0'
		;;
		('libpangoft2-1.0.so.0')
			package_name='libpangoft2-1.0-0'
		;;
		('libpng16.so.16')
			package_name='libpng16-16'
		;;
		('libpthread.so.0')
			package_name='libc6'
		;;
		('libpulse.so.0')
			package_name='libpulse0'
		;;
		('libpulse-simple.so.0')
			package_name='libpulse0'
		;;
		('libresolv.so.2')
			package_name='libc6'
		;;
		('librt.so.1')
			package_name='libc6'
		;;
		('libSDL-1.2.so.0')
			package_name='libsdl1.2debian'
		;;
		('libSDL_mixer-1.2.so.0')
			package_name='libsdl-mixer1.2'
		;;
		('libSDL_ttf-2.0.so.0')
			package_name='libsdl-ttf2.0-0'
		;;
		('libSDL2-2.0.so.0')
			package_name='libsdl2-2.0-0'
		;;
		('libSDL2_ttf-2.0.so.0')
			package_name='libsdl2-ttf-2.0-0'
		;;
		('libSM.so.6')
			package_name='libsm6'
		;;
		('libsmpeg-0.4.so.0')
			package_name='libsmpeg0'
		;;
		('libssl.so.1.1')
			package_name='libssl1.1'
		;;
		('libstdc++.so.5')
			package_name='libstdc++5'
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
		('libuuid.so.1')
			package_name='libuuid1'
		;;
		('libuv.so.1')
			package_name='libuv1'
		;;
		('libvorbisfile.so.3')
			package_name='libvorbisfile3'
		;;
		('libvulkan.so.1')
			package_name='
			libvulkan1
			mesa-vulkan-drivers | vulkan-icd'
		;;
		('libX11.so.6')
			package_name='libx11-6'
		;;
		('libXcursor.so.1')
			package_name='libxcursor1'
		;;
		('libXext.so.6')
			package_name='libxext6'
		;;
		('libXft.so.2')
			package_name='libxft2'
		;;
		('libXinerama.so.1')
			package_name='libxinerama1'
		;;
		('libXrandr.so.2')
			package_name='libxrandr2'
		;;
		('libXxf86vm.so.1')
			package_name='libxxf86vm1'
		;;
		('libxmp.so.4')
			package_name='libxmp4'
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
		local dependency_generic
		while read -r dependency_generic; do
			# pkg_set_deps_deb sets a variable $pkg_deps instead of printing a value,
			# we prevent it from leaking using unset.
			unset pkg_deps
			pkg_set_deps_deb $dependency_generic
			printf '%s\n' "$pkg_deps"
			unset pkg_deps
		done <<- EOL
		$(dependencies_list_generic "$package")
		EOL

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
