# write .deb package meta-data
# USAGE: pkg_write_deb
# NEEDED VARS: GAME_NAME PKG_DEPS_DEB
# CALLED BY: write_metadata
pkg_write_deb() {
	###
	# TODO
	# $pkg should be passed as a function argument, not inherited from the calling function
	# $pkg_path should be computed from $pkg, not inherited from the calling function
	###

	local pkg_deps pkg_size control_directory control_file postinst_script prerm_script

	control_directory="$pkg_path/DEBIAN"
	control_file="$control_directory/control"
	postinst_script="$control_directory/postinst"
	prerm_script="$control_directory/prerm"

	# Get package dependencies list
	use_archive_specific_value "${pkg}_DEPS"
	if [ "$(get_value "${pkg}_DEPS")" ]; then
		# shellcheck disable=SC2046
		pkg_set_deps_deb $(get_value "${pkg}_DEPS")
	fi
	use_archive_specific_value "${pkg}_DEPS_DEB"
	if [ "$(get_value "${pkg}_DEPS_DEB")" ]; then
		if [ -n "$pkg_deps" ]; then
			pkg_deps="$pkg_deps, $(get_value "${pkg}_DEPS_DEB")"
		else
			pkg_deps="$(get_value "${pkg}_DEPS_DEB")"
		fi
	fi

	# Get package size
	pkg_size=$(du --total --block-size=1K --summarize "$pkg_path" | tail --lines=1 | cut --fields=1)

	# Get package version
	PKG="$pkg" \
		get_package_version

	# Create metadata directory, enforce correct permissions
	mkdir --parents "$control_directory"
	chmod 755 "$control_directory"

	# Write main metadata file, enforce correct permissions
	cat > "$control_file" <<- EOF
	Package: $pkg_id
	Version: $PKG_VERSION
	Architecture: $pkg_architecture
	Multi-Arch: foreign
	Maintainer: $pkg_maint
	Installed-Size: $pkg_size
	Section: non-free/games
	EOF
	if [ -n "$pkg_provide" ]; then
		cat >> "$control_file" <<- EOF
		Conflicts: $pkg_provide
		Provides: $pkg_provide
		Replaces: $pkg_provide
		EOF
	fi
	if [ -n "$pkg_deps" ]; then
		cat >> "$control_file" <<- EOF
		Depends: $pkg_deps
		EOF
	fi
	if [ -n "$pkg_description" ]; then
		# shellcheck disable=SC2154
		cat >> "$control_file" <<- EOF
		Description: $GAME_NAME - $pkg_description
		 ./play.it script version $script_version
		EOF
	else
		# shellcheck disable=SC2154
		cat >> "$control_file" <<- EOF
		Description: $GAME_NAME
		 ./play.it script version $script_version
		EOF
	fi
	chmod 644 "$control_file"

	# Write postinst/prerm scripts, enforce correct permissions
	if [ -n "$(get_value "${pkg}_POSTINST_RUN")" ]; then
		cat > "$postinst_script" <<- EOF
		#!/bin/sh -e

		$(get_value "${pkg}_POSTINST_RUN")

		exit 0
		EOF
		chmod 755 "$postinst_script"
	# For compatibility with pre-2.12 scripts, ignored if a package-specific value is already set
	elif [ -e "$postinst" ]; then
		compat_pkg_write_deb_postinst "$postinst_script"
	fi

	if [ -n "$(get_value "${pkg}_PRERM_RUN")" ]; then
		cat > "$prerm_script" <<- EOF
		#!/bin/sh -e

		$(get_value "${pkg}_PRERM_RUN")

		exit 0
		EOF
		chmod 755 "$prerm_script"
	# For compatibility with pre-2.12 scripts, ignored if a package-specific value is already set
	elif [ -e "$prerm" ]; then
		compat_pkg_write_deb_prerm "$prerm_script"
	fi
}

# set list of Debian dependencies from generic names
# USAGE: pkg_set_deps_deb $dep[…]
# CALLED BY: pkg_write_deb
pkg_set_deps_deb() {
	local architecture
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
				pkg_dep='libgdk-pixbuf2.0-0'
			;;
			('glibc')
				pkg_dep='libc6'
			;;
			('libgobject-2.0.so.0'|'libglib-2.0.so.0')
				pkg_dep='libglib2.0-0'
			;;
			('glu'|'libGLU.so.1')
				pkg_dep='libglu1-mesa | libglu1'
			;;
			('glx')
				pkg_dep='libgl1 | libgl1-mesa-glx, libglx-mesa0 | libgl1-mesa-glx'
			;;
			('libgdk-x11-2.0.so.0'|'gtk2')
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
			('libmbedtls.so.12')
				pkg_dep='libmbedtls12'
			;;
			('libpng16.so.16')
				pkg_dep='libpng16-16'
			;;
			('libpulse.so.0'|'libpulse-simple.so.0')
				pkg_dep='libpulse0'
			;;
			('libstdc++')
				pkg_dep='libstdc++6'
			;;
			('libudev1')
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
			('wine')
				use_archive_specific_value "${pkg}_ARCH"
				architecture="$(get_value "${pkg}_ARCH")"
				case "$architecture" in
					('32') pkg_set_deps_deb 'wine32' ;;
					('64') pkg_set_deps_deb 'wine64' ;;
				esac
			;;
			('wine32')
				pkg_dep='wine32 | wine32-development | wine-bin | wine-i386 | wine-staging-i386, wine'
			;;
			('wine64')
				pkg_dep='wine64 | wine64-development | wine64-bin | wine-amd64 | wine-staging-amd64, wine'
			;;
			('wine-staging')
				use_archive_specific_value "${pkg}_ARCH"
				architecture="$(get_value "${pkg}_ARCH")"
				case "$architecture" in
					('32') pkg_set_deps_deb 'wine32-staging' ;;
					('64') pkg_set_deps_deb 'wine64-staging' ;;
				esac
			;;
			('wine32-staging')
				pkg_dep='wine-staging-i386, winehq-staging:amd64 | winehq-staging'
			;;
			('wine64-staging')
				pkg_dep='wine-staging-amd64, winehq-staging'
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

# build .deb package
# USAGE: pkg_build_deb $pkg_path
# NEEDED VARS: (OPTION_COMPRESSION) (LANG) PLAYIT_WORKDIR
# CALLED BY: build_pkg
pkg_build_deb() {
	local pkg_filename
	pkg_filename="$OPTION_OUTPUT_DIR/$(basename "$1").deb"
	if [ -e "$pkg_filename" ] && [ $OVERWRITE_PACKAGES -ne 1 ]; then
		information_package_already_exists "$(basename "$pkg_filename")"
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg?}_PKG
		return 0
	fi

	local dpkg_options
	case $OPTION_COMPRESSION in
		('gzip'|'none'|'xz')
			dpkg_options="-Z$OPTION_COMPRESSION"
		;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_build_deb'
		;;
	esac


	information_package_building "$(basename "$pkg_filename")"
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '\n'
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg?}_PKG
		return 0
	fi
	TMPDIR="$PLAYIT_WORKDIR" fakeroot -- dpkg-deb $dpkg_options --build "$1" "$pkg_filename" 1>/dev/null
	eval ${pkg}_PKG=\"$pkg_filename\"
	export ${pkg?}_PKG

	print_ok
}

