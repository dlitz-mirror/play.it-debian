# write .pkg.tar package meta-data
# USAGE: pkg_write_arch
# NEEDED VARS: GAME_NAME PKG_DEPS_ARCH
# CALLED BY: write_metadata
pkg_write_arch() {
	local pkg_id_orig
	pkg_id_orig="$pkg_id"
	use_archive_specific_value "${pkg}_ARCH"
	local architecture
	architecture="$(get_value "${pkg}_ARCH")"
	if [ "$architecture" = '32' ]; then
		pkg_id="lib32-$pkg_id"
	fi
	local pkg_deps
	use_archive_specific_value "${pkg}_DEPS"
	if [ "$(get_value "${pkg}_DEPS")" ]; then
		# shellcheck disable=SC2046
		pkg_set_deps_arch $(get_value "${pkg}_DEPS")
	fi
	use_archive_specific_value "${pkg}_DEPS_ARCH"
	if [ "$(get_value "${pkg}_DEPS_ARCH")" ]; then
		pkg_deps="$pkg_deps $(get_value "${pkg}_DEPS_ARCH")"
	fi
	local pkg_size
	pkg_size=$(du --total --block-size=1 --summarize "$pkg_path" | tail --lines=1 | cut --fields=1)
	local target
	target="$pkg_path/.PKGINFO"

	PKG="$pkg"
	get_package_version

	mkdir --parents "$(dirname "$target")"

	cat > "$target" <<- EOF
	# Generated by ./play.it $LIBRARY_VERSION
	pkgname = $pkg_id
	pkgver = $PKG_VERSION
	packager = $pkg_maint
	builddate = $(date +%s)
	size = $pkg_size
	arch = $pkg_architecture
	EOF

	if [ -n "$pkg_description" ]; then
		# shellcheck disable=SC2154
		cat >> "$target" <<- EOF
		pkgdesc = $GAME_NAME - $pkg_description - ./play.it script version $script_version
		EOF
	else
		# shellcheck disable=SC2154
		cat >> "$target" <<- EOF
		pkgdesc = $GAME_NAME - ./play.it script version $script_version
		EOF
	fi

	for dep in $pkg_deps; do
		cat >> "$target" <<- EOF
		depend = $dep
		EOF
	done

	if [ -n "$pkg_provide" ]; then
		cat >> "$target" <<- EOF
		conflict = $pkg_provide
		provides = $pkg_provide
		EOF
	fi

	if [ "$architecture" = '32' ]; then
		cat >> "$target" <<- EOF
		conflict = $pkg_id_orig
		provides = $pkg_id_orig
		EOF
	fi

	target="$pkg_path/.INSTALL"

	if [ -n "$(get_value "${pkg}_POSTINST_RUN")" ]; then
		cat >> "$target" <<- EOF
		post_install() {
		$(get_value "${pkg}_POSTINST_RUN")
		}

		post_upgrade() {
		post_install
		}
		EOF
	# For compatibility with pre-2.12 scripts, ignored if a package-specific value is already set
	elif [ -e "$postinst" ]; then
		compat_pkg_write_arch_postinst "$target"
	fi

	if [ -n "$(get_value "${pkg}_PRERM_RUN")" ]; then
		cat >> "$target" <<- EOF
		pre_remove() {
		$(get_value "${pkg}_PRERM_RUN")
		}

		pre_upgrade() {
		pre_remove
		}
		EOF
	# For compatibility with pre-2.12 scripts, ignored if a package-specific value is already set
	elif [ -e "$postinst" ]; then
		compat_pkg_write_arch_prerm "$target"
	fi

	# Creates .MTREE
	package_archlinux_create_mtree "$pkg_path"
}

# set list or Arch Linux dependencies from generic names
# USAGE: pkg_set_deps_arch $dep[…]
# CALLS: pkg_set_deps_arch32 pkg_set_deps_arch64
# CALLED BY: pkg_write_arch
pkg_set_deps_arch() {
	case $architecture in
		('32')
			pkg_set_deps_arch32 "$@"
		;;
		(*)
			pkg_set_deps_arch64 "$@"
		;;
	esac
}

# set list or Arch Linux 32-bit dependencies from generic names
# USAGE: pkg_set_deps_arch32 $dep[…]
# CALLS: warning_missing_library
# CALLED BY: pkg_set_deps_arch
pkg_set_deps_arch32() {
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep='lib32-alsa-lib lib32-alsa-plugins'
			;;
			('bzip2')
				pkg_dep='lib32-bzip2'
			;;
			('dosbox')
				pkg_dep='dosbox'
			;;
			('freetype')
				pkg_dep='lib32-freetype2'
			;;
			('gcc32')
				pkg_dep='gcc-multilib lib32-gcc-libs'
			;;
			('gconf')
				pkg_dep='lib32-gconf'
			;;
			('libgdk_pixbuf-2.0.so.0')
				pkg_dep='lib32-gdk-pixbuf2'
			;;
			('glibc')
				pkg_dep='lib32-glibc'
			;;
			('libglib-2.0.so.0'|'libgobject-2.0.so.0')
				pkg_dep='lib32-glib2'
			;;
			('glu'|'libGLU.so.1')
				pkg_dep='lib32-glu'
			;;
			('glx')
				pkg_dep='lib32-libgl'
			;;
			('libgdk-x11-2.0.so.0'|'gtk2')
				pkg_dep='lib32-gtk2'
			;;
			('java')
				pkg_dep='jre8-openjdk'
			;;
			('json')
				pkg_dep='lib32-json-c'
			;;
			('libasound.so.2')
				pkg_dep='lib32-alsa-lib'
			;;
			('libasound_module_'*'.so')
				pkg_dep='lib32-alsa-plugins'
			;;
			('libcurl')
				pkg_dep='lib32-curl'
			;;
			('libcurl-gnutls')
				pkg_dep='lib32-libcurl-gnutls'
			;;
			('libmbedtls.so.12')
				warning_missing_library 'libmbedtls.so.12' 'Arch Linux' '32bits'
			;;
			('libpng16.so.16')
				pkg_dep='lib32-libpng'
			;;
			('libpulse.so.0'|'libpulse-simple.so.0')
				pkg_dep='lib32-libpulse'
			;;
			('libstdc++')
				pkg_dep='lib32-gcc-libs'
			;;
			('libudev1')
				pkg_dep='lib32-systemd'
			;;
			('libX11.so.6')
				pkg_dep='lib32-libx11'
			;;
			('libxrandr')
				pkg_dep='lib32-libxrandr'
			;;
			('nss')
				pkg_dep='lib32-nss'
			;;
			('openal'|'libopenal.so.1')
				pkg_dep='lib32-openal'
			;;
			('pulseaudio')
				pkg_dep='pulseaudio'
			;;
			('sdl1.2'|'libSDL-1.2.so.0')
				pkg_dep='lib32-sdl'
			;;
			('sdl2'|'libSDL2-2.0.so.0')
				pkg_dep='lib32-sdl2'
			;;
			('sdl2_image')
				pkg_dep='lib32-sdl2_image'
			;;
			('sdl2_mixer')
				pkg_dep='lib32-sdl2_mixer'
			;;
			('theora')
				pkg_dep='lib32-libtheora'
			;;
			('libturbojpeg.so.0')
				pkg_dep='lib32-libjpeg-turbo'
			;;
			('libuv.so.1')
				warning_missing_library 'libuv.so.1' 'Arch Linux' '32bits'
			;;
			('vorbis'|'libvorbisfile.so.3')
				pkg_dep='lib32-libvorbis'
			;;
			('wine'|'wine32'|'wine64')
				pkg_dep='wine'
			;;
			('wine-staging'|'wine32-staging'|'wine64-staging')
				pkg_dep='wine-staging'
			;;
			('winetricks')
				pkg_dep='winetricks xterm'
			;;
			('xcursor')
				pkg_dep='lib32-libxcursor'
			;;
			('xft')
				pkg_dep='lib32-libxft'
			;;
			('xgamma')
				pkg_dep='xorg-xgamma'
			;;
			('xrandr')
				pkg_dep='xorg-xrandr'
			;;
			('libz.so.1')
				pkg_dep='lib32-zlib'
			;;
			(*)
				pkg_dep="$dep"
			;;
		esac
		pkg_deps="$pkg_deps $pkg_dep"
	done
}

# set list or Arch Linux 64-bit dependencies from generic names
# USAGE: pkg_set_deps_arch64 $dep[…]
# CALLED BY: pkg_set_deps_arch
pkg_set_deps_arch64() {
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep='alsa-lib alsa-plugins'
			;;
			('bzip2')
				pkg_dep='bzip2'
			;;
			('dosbox')
				pkg_dep='dosbox'
			;;
			('freetype')
				pkg_dep='freetype2'
			;;
			('gcc32')
				pkg_dep='gcc-multilib lib32-gcc-libs'
			;;
			('gconf')
				pkg_dep='gconf'
			;;
			('libgdk_pixbuf-2.0.so.0')
				pkg_dep='gdk-pixbuf2'
			;;
			('glibc')
				pkg_dep='glibc'
			;;
			('libgobject-2.0.so.0'|'libglib-2.0.so.0')
				pkg_dep='glib2'
			;;
			('glu'|'libGLU.so.1')
				pkg_dep='glu'
			;;
			('glx')
				pkg_dep='libgl'
			;;
			('libgdk-x11-2.0.so.0'|'gtk2')
				pkg_dep='gtk2'
			;;
			('java')
				pkg_dep='jre8-openjdk'
			;;
			('json')
				pkg_dep='json-c'
			;;
			('libasound.so.2')
				pkg_dep='alsa-lib'
			;;
			('libasound_module_'*'.so')
				pkg_dep='alsa-plugins'
			;;
			('libcurl')
				pkg_dep='curl'
			;;
			('libcurl-gnutls')
				pkg_dep='libcurl-gnutls'
			;;
			('libmbedtls.so.12')
				pkg_dep='mbedtls'
			;;
			('libpng16.so.16')
				pkg_dep='libpng'
			;;
			('libpulse.so.0'|'libpulse-simple.so.0')
				pkg_dep='libpulse'
			;;
			('libstdc++')
				pkg_dep='gcc-libs'
			;;
			('libudev1')
				pkg_dep='libsystemd'
			;;
			('libX11.so.6')
				pkg_dep='libx11'
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
			('openal'|'libopenal.so.1')
				pkg_dep='openal'
			;;
			('pulseaudio')
				pkg_dep='pulseaudio'
			;;
			('sdl1.2'|'libSDL-1.2.so.0')
				pkg_dep='sdl'
			;;
			('sdl2'|'libSDL2-2.0.so.0')
				pkg_dep='sdl2'
			;;
			('sdl2_image')
				pkg_dep='sdl2_image'
			;;
			('sdl2_mixer')
				pkg_dep='sdl2_mixer'
			;;
			('theora')
				pkg_dep='libtheora'
			;;
			('libturbojpeg.so.0')
				pkg_dep='libjpeg-turbo'
			;;
			('libuv.so.1')
				pkg_dep='libuv'
			;;
			('vorbis'|'libvorbisfile.so.3')
				pkg_dep='libvorbis'
			;;
			('wine'|'wine32'|'wine64')
				pkg_dep='wine'
			;;
			('winetricks')
				pkg_dep='winetricks'
			;;
			('xcursor')
				pkg_dep='libxcursor'
			;;
			('xft')
				pkg_dep='libxft'
			;;
			('xgamma')
				pkg_dep='xorg-xgamma'
			;;
			('xrandr')
				pkg_dep='xorg-xrandr'
			;;
			('libz.so.1')
				pkg_dep='zlib'
			;;
			(*)
				pkg_dep="$dep"
			;;
		esac
		pkg_deps="$pkg_deps $pkg_dep"
	done
}

# build .pkg.tar package
# USAGE: pkg_build_arch $pkg_path
# NEEDED VARS: (OPTION_COMPRESSION) (LANG) PLAYIT_WORKDIR
# CALLED BY: build_pkg
pkg_build_arch() {
	local pkg_filename
	pkg_filename=$(realpath "$OPTION_OUTPUT_DIR/$(basename "$1").pkg.tar")

	if [ -e "$pkg_filename" ] && [ $OVERWRITE_PACKAGES -ne 1 ]; then
		information_package_already_exists "$(basename "$pkg_filename")"
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg?}_PKG
		return 0
	fi

	local tar_options
	tar_options='--create'
	if [ -z "$PLAYIT_TAR_IMPLEMENTATION" ]; then
		guess_tar_implementation
	fi
	case "$PLAYIT_TAR_IMPLEMENTATION" in
		('gnutar')
			tar_options="$tar_options --group=root --owner=root"
		;;
		('bsdtar')
			tar_options="$tar_options --gname=root --uname=root"
		;;
		(*)
			error_unknown_tar_implementation
		;;
	esac

	case $OPTION_COMPRESSION in
		('gzip')
			tar_options="$tar_options --gzip"
			pkg_filename="${pkg_filename}.gz"
		;;
		('xz')
			export XZ_DEFAULTS="${XZ_DEFAULTS:=--threads=0}"
			tar_options="$tar_options --xz"
			pkg_filename="${pkg_filename}.xz"
		;;
		('bzip2')
			tar_options="$tar_options --bzip2"
			pkg_filename="${pkg_filename}.bz2"
		;;
		('none') ;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_build_arch'
		;;
	esac

	information_package_building "$(basename "$pkg_filename")"
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '\n'
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg?}_PKG
		return 0
	fi

	(
		cd "$1"
		local files
		files='.MTREE .PKGINFO *'
		if [ -e '.INSTALL' ]; then
			files=".INSTALL $files"
		fi
		tar $tar_options --file "$pkg_filename" $files
	)

	eval ${pkg}_PKG=\"$pkg_filename\"
	export ${pkg?}_PKG

	print_ok
}

# creates .MTREE in package
# USAGE: package_archlinux_create_mtree $pkg_path
# RETURNS: nothing
package_archlinux_create_mtree() {
	local pkg_path
	pkg_path="$1"

	(
		cd "$pkg_path"
		# shellcheck disable=SC2030
		export LANG=C
		# shellcheck disable=SC2094
		find . -print0 | bsdtar \
			--create \
			--file - \
			--files-from - \
			--format=mtree \
			--no-recursion \
			--null \
			--options='!all,use-set,type,uid,gid,mode,time,size,md5,sha256,link' \
			--exclude .MTREE \
			| gzip \
			--force \
			--no-name \
			--to-stdout \
			> .MTREE
	)

	return 0
}
