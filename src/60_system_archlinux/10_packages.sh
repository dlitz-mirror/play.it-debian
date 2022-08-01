# write .pkg.tar package meta-data
# USAGE: pkg_write_arch
pkg_write_arch() {
	###
	# TODO
	# $pkg should be passed as a function argument, not inherited from the calling function
	###

	local package_path
	package_path=$(package_get_path "$pkg")

	local pkg_deps dependencies_string
	dependencies_string=$(get_context_specific_value 'archive' "${pkg}_DEPS")
	if [ -n "$dependencies_string" ]; then
		# shellcheck disable=SC2046
		pkg_set_deps_arch $dependencies_string
	fi

	local dependencies_string_arch
	dependencies_string_arch=$(get_context_specific_value 'archive' "${pkg}_DEPS_ARCH")
	if [ -n "$dependencies_string_arch" ]; then
		pkg_deps="$pkg_deps $dependencies_string_arch"
	fi

	local pkg_size
	pkg_size=$(du --total --block-size=1 --summarize "$package_path" | tail --lines=1 | cut --fields=1)
	local target
	target="${package_path}/.PKGINFO"

	mkdir --parents "$(dirname "$target")"

	cat > "$target" <<- EOF
	# Generated by ./play.it $LIBRARY_VERSION
	pkgname = $(package_get_id "$pkg")
	pkgver = $(packages_get_version "$ARCHIVE")
	packager = $(packages_get_maintainer)
	builddate = $(date +%s)
	size = $pkg_size
	arch = $(package_get_architecture_string "$pkg")
	pkgdesc = $(package_get_description "$pkg")
	EOF

	for dep in $pkg_deps; do
		cat >> "$target" <<- EOF
		depend = $dep
		EOF
	done

	if [ -n "$(package_get_provide "$pkg")" ]; then
		cat >> "$target" <<- EOF
		conflict = $(package_get_provide "$pkg")
		provides = $(package_get_provide "$pkg")
		EOF
	fi

	if [ "$(package_get_architecture "$pkg")" = '32' ]; then
		cat >> "$target" <<- EOF
		conflict = $(package_get_id "$pkg" |sed 's/^lib32-//')
		provides = $(package_get_id "$pkg" |sed 's/^lib32-//')
		EOF
	fi

	target="${package_path}/.INSTALL"

	if [ -n "$(get_value "${pkg}_POSTINST_RUN")" ]; then
		cat >> "$target" <<- EOF
		post_install() {
		$(get_value "${pkg}_POSTINST_RUN")
		}

		post_upgrade() {
		post_install
		}
		EOF
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
	fi

	# Creates .MTREE
	if [ "$MTREE" -eq 1 ]; then
		package_archlinux_create_mtree "$pkg"
	fi
}

# set list or Arch Linux dependencies from generic names
# USAGE: pkg_set_deps_arch $dep[…]
# CALLS: pkg_set_deps_arch32 pkg_set_deps_arch64
# CALLED BY: pkg_write_arch
pkg_set_deps_arch() {
	case "$(package_get_architecture "$pkg")" in
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
			('libc.so.6'|'glibc')
				pkg_dep='lib32-glibc'
			;;
			('libglib-2.0.so.0'|'libgobject-2.0.so.0')
				pkg_dep='lib32-glib2'
			;;
			('glu'|'libGLU.so.1')
				pkg_dep='lib32-glu'
			;;
			('libGL.so.1'|'glx')
				pkg_dep='lib32-libgl'
			;;
			('libgdk-x11-2.0.so.0'|'libgtk-x11-2.0.so.0'|'gtk2')
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
			('libstdc++.so.6'|'libstdc++')
				pkg_dep='lib32-gcc-libs'
			;;
			('libudev1'|'libudev.so.1')
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
			('renpy')
				pkg_dep='renpy'
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
			('libc.so.6'|'glibc')
				pkg_dep='glibc'
			;;
			('libgobject-2.0.so.0'|'libglib-2.0.so.0')
				pkg_dep='glib2'
			;;
			('glu'|'libGLU.so.1')
				pkg_dep='glu'
			;;
			('libGL.so.1'|'glx')
				pkg_dep='libgl'
			;;
			('libgdk-x11-2.0.so.0'|'libgtk-x11-2.0.so.0'|'gtk2')
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
			('libstdc++.so.6'|'libstdc++')
				pkg_dep='gcc-libs'
			;;
			('libudev1'|'libudev.so.1')
				pkg_dep='libudev.so=1-64'
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
			('renpy')
				pkg_dep='renpy'
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
			return 1
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
		('zstd')
			tar_options="$tar_options --zstd"
			pkg_filename="${pkg_filename}.zst"
		;;
		('none') ;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_build_arch'
			return 1
		;;
	esac

	information_package_building "$(basename "$pkg_filename")"

	(
		cd "$1"
		local files
		files='.PKGINFO *'
		if [ -e '.INSTALL' ]; then
			files=".INSTALL $files"
		fi
		if [ -e '.MTREE' ]; then
			files=".MTREE $files"
		fi
		debug_external_command "tar $tar_options --file \"$pkg_filename\" $files"
		tar $tar_options --file "$pkg_filename" $files
	)

	eval ${pkg}_PKG=\"$pkg_filename\"
	export ${pkg?}_PKG

	information_package_building_done
}

# creates .MTREE in package
# USAGE: package_archlinux_create_mtree $pkg_path
# RETURNS: nothing
package_archlinux_create_mtree() {
	local pkg
	local pkg_path
	pkg="$1"
	pkg_path="$(package_get_path "$pkg")"

	info_package_mtree_computation "$pkg"
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
	info_package_mtree_computation_done

	return 0
}
