# write .ebuild package meta-data
# USAGE: pkg_write_gentoo
# NEEDED VARS: GAME_NAME PKG_DEPS_GENTOO
# CALLED BY: write_metadata
pkg_write_gentoo() {
	local pkg_deps
	use_archive_specific_value "${pkg}_DEPS"
	if [ "$(get_value "${pkg}_DEPS")" ]; then
		# shellcheck disable=SC2046
		pkg_set_deps_gentoo $(get_value "${pkg}_DEPS")
		export GENTOO_OVERLAYS
	fi
	use_archive_specific_value "${pkg}_DEPS_GENTOO"
	if [ "$(get_value "${pkg}_DEPS_GENTOO")" ]; then
		pkg_deps="$pkg_deps $(get_value "${pkg}_DEPS_GENTOO")"
	fi

	if [ -n "$(package_get_provide "$pkg")" ]; then
		pkg_deps="${pkg_deps} $(package_get_provide "$pkg")"
	fi

	mkdir --parents \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/metadata" \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/profiles" \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/$(package_get_id "$pkg")/files"
	printf '%s\n' "masters = gentoo" > "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/metadata/layout.conf"
	printf '%s\n' 'games-playit' > "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/profiles/categories"
	ln --symbolic --force --no-target-directory "$pkg_path" "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/$(package_get_id "$pkg")/files/install"
	local target
	target="$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/$(package_get_id "$pkg")/$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").ebuild"

	cat > "$target" <<- EOF
	EAPI=7
	RESTRICT="fetch strip binchecks"
	EOF
	local pkg_architectures
	set_supported_architectures "$pkg"
	cat >> "$target" <<- EOF
	KEYWORDS="$pkg_architectures"
	DESCRIPTION="$(package_get_description "$pkg")"
	SLOT="0"
	EOF

	# fowners is needed to make sure all files in the generated package belong to root (arch linux packages use tar options that do the same thing)
	cat >> "$target" <<- EOF
	RDEPEND="$pkg_deps"

	src_unpack() {
		mkdir --parents "\$S"
	}
	src_install() {
		cp --recursive --link \$FILESDIR/install/* \$ED/
		fowners --recursive root:root /
	}
	EOF

	if [ -n "$(get_value "${pkg}_POSTINST_RUN")" ]; then
		cat >> "$target" <<- EOF
		pkg_postinst() {
		$(get_value "${pkg}_POSTINST_RUN")
		}
		EOF
	# For compatibility with pre-2.12 scripts, ignored if a package-specific value is already set
	elif [ -e "$postinst" ]; then
		compat_pkg_write_gentoo_postinst "$target"
	fi

	if [ -n "$(get_value "${pkg}_PRERM_RUN")" ]; then
		cat >> "$target" <<- EOF
		pkg_prerm() {
		$(get_value "${pkg}_PRERM_RUN")
		}
		EOF
	# For compatibility with pre-2.12 scripts, ignored if a package-specific value is already set
	elif [ -e "$prerm" ]; then
		compat_pkg_write_gentoo_prerm "$target"
	fi
}

# set list or Gentoo Linux dependencies from generic names
# USAGE: pkg_set_deps_gentoo $dep[…]
# CALLED BY: pkg_write_gentoo
pkg_set_deps_gentoo() {
	local architecture_suffix
	local architecture_suffix_use
	case "$(package_get_architecture "$pkg")" in
		('32')
			architecture_suffix='[abi_x86_32]'
			architecture_suffix_use=',abi_x86_32'
		;;
		('64')
			architecture_suffix=''
			architecture_suffix_use=''
		;;
	esac
	for dep in "$@"; do
		case $dep in
			('alsa')
				pkg_dep="media-libs/alsa-lib$architecture_suffix media-plugins/alsa-plugins$architecture_suffix"
			;;
			('bzip2')
				pkg_dep="app-arch/bzip2$architecture_suffix"
			;;
			('dosbox')
				pkg_dep="games-emulation/dosbox"
			;;
			('freetype')
				pkg_dep="media-libs/freetype$architecture_suffix"
			;;
			('gcc32')
				pkg_dep='' #gcc (in @system) should be multilib unless it is a no-multilib profile, in which case the 32 bits libraries wouldn't work
			;;
			('gconf')
				pkg_dep="gnome-base/gconf$architecture_suffix"
			;;
			('libgdk_pixbuf-2.0.so.0')
				pkg_dep="x11-libs/gdk-pixbuf:2$architecture_suffix"
			;;
			('glibc')
				pkg_dep="sys-libs/glibc"
				if [ "$(package_get_architecture "$pkg")" = '32' ]; then
					pkg_dep="$pkg_dep amd64? ( sys-libs/glibc[multilib] )"
				fi
			;;
			('libglib-2.0.so.0'|'libgobject-2.0.so.0')
				pkg_dep="dev-libs/glib:2$architecture_suffix"
			;;
			('glu'|'libGLU.so.1')
				pkg_dep="virtual/glu$architecture_suffix"
			;;
			('glx')
				pkg_dep="virtual/opengl$architecture_suffix"
			;;
			('libgdk-x11-2.0.so.0'|'gtk2')
				pkg_dep="x11-libs/gtk+:2$architecture_suffix"
			;;
			('java')
				pkg_dep='virtual/jre'
			;;
			('json')
				pkg_dep="dev-libs/json-c$architecture_suffix"
			;;
			('libasound.so.2')
				pkg_dep="media-libs/alsa-lib${architecture_suffix}"
			;;
			('libasound_module_'*'.so')
				pkg_dep="media-plugins/alsa-plugins${architecture_suffix}"
			;;
			('libcurl')
				pkg_dep="net-misc/curl$architecture_suffix"
			;;
			('libcurl-gnutls')
				pkg_dep="net-libs/libcurl-debian$architecture_suffix"
				pkg_overlay='steam-overlay'
			;;
			('libmbedtls.so.12')
				pkg_dep="net-libs/mbedtls:0/12$architecture_suffix"
			;;
			('libpng16.so.16')
				pkg_dep="media-libs/libpng:0/16$architecture_suffix"
			;;
			('libpulse.so.0'|'libpulse-simple.so.0')
				pkg_dep="media-sound/pulseaudio${architecture_suffix}"
			;;
			('libstdc++')
				pkg_dep='' #maybe this should be virtual/libstdc++, otherwise, it is included in gcc, which should be in @system
			;;
			('libudev1')
				pkg_dep="virtual/libudev$architecture_suffix"
			;;
			('libX11.so.6')
				pkg_dep="x11-libs/libX11${architecture_suffix}"
			;;
			('libxrandr')
				pkg_dep="x11-libs/libXrandr$architecture_suffix"
			;;
			('mono')
				pkg_dep="dev-lang/mono$architecture_suffix"
			;;
			('nss')
				pkg_dep="dev-libs/nss$architecture_suffix"
			;;
			('openal'|'libopenal.so.1')
				pkg_dep="media-libs/openal$architecture_suffix"
			;;
			('pulseaudio')
				pkg_dep='media-sound/pulseaudio'
			;;
			('renpy')
				pkg_dep='games-engines/renpy'
			;;
			('sdl1.2'|'libSDL-1.2.so.0')
				pkg_dep="media-libs/libsdl$architecture_suffix"
			;;
			('sdl2'|'libSDL2-2.0.so.0')
				pkg_dep="media-libs/libsdl2$architecture_suffix"
			;;
			('sdl2_image')
				pkg_dep="media-libs/sdl2-image$architecture_suffix"
			;;
			('sdl2_mixer')
				#Most games will require at least one of flac, mp3, vorbis or wav USE flags, it should better to require them all instead of not requiring any and having non-fonctionnal sound in some games.
				pkg_dep="media-libs/sdl2-mixer[flac,mp3,vorbis,wav$architecture_suffix_use]"
			;;
			('theora')
				pkg_dep="media-libs/libtheora$architecture_suffix"
			;;
			('libturbojpeg.so.0')
				pkg_dep="media-libs/libjpeg-turbo$architecture_suffix"
			;;
			('libuv.so.1')
				pkg_dep="dev-libs/libuv:0/1$architecture_suffix"
			;;
			('vorbis'|'libvorbisfile.so.3')
				pkg_dep="media-libs/libvorbis$architecture_suffix"
			;;
			('wine')
				case "$(package_get_architecture "$pkg")" in
					('32') pkg_set_deps_gentoo 'wine32' ;;
					('64') pkg_set_deps_gentoo 'wine64' ;;
				esac
			;;
			('wine32')
				pkg_dep='virtual/wine[abi_x86_32]'
			;;
			('wine64')
				pkg_dep='virtual/wine[abi_x86_64]'
			;;
			('wine-staging')
				case "$(package_get_architecture "$pkg")" in
					('32') pkg_set_deps_gentoo 'wine32-staging' ;;
					('64') pkg_set_deps_gentoo 'wine64-staging' ;;
				esac
			;;
			('wine32-staging')
				pkg_dep='virtual/wine[staging,abi_x86_32]'
			;;
			('wine64-staging')
				pkg_dep='virtual/wine[staging,abi_x86_64]'
			;;
			('winetricks')
				pkg_dep='app-emulation/winetricks
				|| (
					x11-terms/xterm
					gnome-extra/zenity
					kde-apps/kdialog
				)'
			;;
			('xcursor')
				pkg_dep="x11-libs/libXcursor$architecture_suffix"
			;;
			('xft')
				pkg_dep="x11-libs/libXft$architecture_suffix"
			;;
			('xgamma')
				pkg_dep='x11-apps/xgamma'
			;;
			('xrandr')
				pkg_dep='x11-apps/xrandr'
			;;
			('libz.so.1')
				pkg_dep="sys-libs/zlib:0/1$architecture_suffix"
			;;
			(*)
				pkg_dep="games-playit/$(printf '%s' "$dep" | sed 's/-/_/g')"
				# shellcheck disable=SC2039
				local package
				for package in $PACKAGES_LIST; do
					if [ "$package" != "$pkg" ]; then
						if [ "$(package_get_provide "$package")" = $(printf '%s' "!!games-playit/${dep}" | sed 's/-/_/g') ]; then
							pkg_dep="|| ( ${pkg_dep} )"
						fi
					fi
				done
			;;
		esac
		pkg_deps="$pkg_deps $pkg_dep"
		if [ -n "$pkg_overlay" ]; then
			if ! printf '%s' "$GENTOO_OVERLAYS" | sed --regexp-extended 's/\s+/\n/g' | grep --fixed-strings --line-regexp --quiet "$pkg_overlay"; then
				GENTOO_OVERLAYS="$GENTOO_OVERLAYS $pkg_overlay"
			fi
			pkg_overlay=''
		fi
	done
}

# build .tbz2 gentoo package
# USAGE: pkg_build_gentoo $pkg_path
# NEEDED VARS: (LANG) PLAYIT_WORKDIR
# CALLED BY: build_pkg
pkg_build_gentoo() {
	local pkg_filename_base="$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").tbz2"

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	for package in $packages_list; do
		if [ "$package" != "$pkg" ] && [ "$(package_get_id "$package")" = "$(package_get_id "$pkg")" ]; then
			pkg_filename_base="$(package_get_architecture_string "$pkg")/$pkg_filename_base"
			mkdir --parents "$(dirname "$pkg_filename_base")"
		fi
	done
	local pkg_filename
	pkg_filename="$OPTION_OUTPUT_DIR/$pkg_filename_base"

	if [ -e "$pkg_filename" ] && [ $OVERWRITE_PACKAGES -ne 1 ]; then
		information_package_already_exists "$pkg_filename_base"
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg}_PKG
		return 0
	fi

	information_package_building "$pkg_filename_base"
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '\n'
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg}_PKG
		return 0
	fi

	mkdir --parents "$PLAYIT_WORKDIR/portage-tmpdir"
	local ebuild_path="$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/$(package_get_id "$pkg")/$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").ebuild"
	ebuild "$ebuild_path" manifest 1>/dev/null
	PORTAGE_TMPDIR="$PLAYIT_WORKDIR/portage-tmpdir" PKGDIR="$PLAYIT_WORKDIR/gentoo-pkgdir" BINPKG_COMPRESS="$OPTION_COMPRESSION" fakeroot-ng -- ebuild "$ebuild_path" package 1>/dev/null
	mv "$PLAYIT_WORKDIR/gentoo-pkgdir/games-playit/$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").tbz2" "$pkg_filename"
	rm --recursive "$PLAYIT_WORKDIR/portage-tmpdir"

	eval ${pkg}_PKG=\"$pkg_filename\"
	export ${pkg}_PKG

	print_ok
}

