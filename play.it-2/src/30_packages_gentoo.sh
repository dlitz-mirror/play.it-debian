# Get packages that provides the given package
# USAGE: gentoo_get_pkg_providers $provided_package
# NEEDED VARS: PACKAGES_LIST pkg
# CALLED BY: pkg_write_gentoo pkg_set_deps_gentoo
gentoo_get_pkg_providers() {
	local provided="$1"
	for package in $PACKAGES_LIST; do
		if [ "$package" != "$pkg" ]; then
			use_archive_specific_value "${package}_ID"
			if [ "$(get_value "${package}_PROVIDE")" = "$provided" ]; then
				printf '%s\n' "$(get_value "${package}_ID")"
			fi
		fi
	done
}

# write .ebuild package meta-data
# USAGE: pkg_write_gentoo
# NEEDED VARS: GAME_NAME PKG_DEPS_GENTOO
# CALLS: gentoo_get_pkg_providers
# CALLED BY: write_metadata
pkg_write_gentoo() {
	pkg_id="$(printf '%s' "$pkg_id" | sed 's/-/_/g')" # This makes sure numbers in the package name doesn't get interpreted as a version by portage

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

	if [ -n "$pkg_provide" ]; then
		for package_provide in $pkg_provide; do
			pkg_deps="$pkg_deps $(gentoo_get_pkg_providers "$package_provide" | sed -e 's/-/_/g' -e 's|^|!!games-playit/|')"
		done
	fi

	PKG="$pkg"
	get_package_version

	mkdir --parents \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/metadata" \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/profiles" \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/$pkg_id/files"
	printf '%s\n' "masters = gentoo" > "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/metadata/layout.conf"
	printf '%s\n' 'games-playit' > "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/profiles/categories"
	ln --symbolic --force --no-target-directory "$pkg_path" "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/$pkg_id/files/install"
	local target
	target="$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/$pkg_id/$pkg_id-$PKG_VERSION.ebuild"

	cat > "$target" <<- EOF
	EAPI=7
	RESTRICT="fetch strip binchecks"
	EOF
	local pkg_architectures
	set_supported_architectures "$PKG"
	cat >> "$target" <<- EOF
	KEYWORDS="$pkg_architectures"
	EOF

	if [ -n "$pkg_description" ]; then
		cat >> "$target" <<- EOF
		DESCRIPTION="$GAME_NAME - $pkg_description - ./play.it script version $script_version"
		EOF
	else
		cat >> "$target" <<- EOF
		DESCRIPTION="$GAME_NAME - ./play.it script version $script_version"
		EOF
	fi

	cat >> "$target" <<- EOF
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

	if [ -e "$postinst" ]; then
		cat >> "$target" <<- EOF
		pkg_postinst() {
		$(cat "$postinst")
		}
		EOF
	fi

	if [ -e "$prerm" ]; then
		cat >> "$target" <<- EOF
		pkg_prerm() {
		$(cat "$prerm")
		}
		EOF
	fi
}

# set list or Gentoo Linux dependencies from generic names
# USAGE: pkg_set_deps_gentoo $dep[…]
# CALLS: gentoo_get_pkg_providers
# CALLED BY: pkg_write_gentoo
pkg_set_deps_gentoo() {
	use_archive_specific_value "${pkg}_ARCH"
	local architecture
	architecture="$(get_value "${pkg}_ARCH")"
	local architecture_suffix
	local architecture_suffix_use
	case $architecture in
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
			('glibc')
				pkg_dep="sys-libs/glibc"
				if [ "$architecture" = '32' ]; then
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
			('java')
				pkg_dep='virtual/jre'
			;;
			('json')
				pkg_dep="dev-libs/json-c$architecture_suffix"
			;;
			('libcurl')
				pkg_dep="net-misc/curl$architecture_suffix"
			;;
			('libcurl-gnutls')
				pkg_dep="net-libs/libcurl-debian$architecture_suffix"
				pkg_overlay='steam-overlay'
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
			('pulseaudio')
				pkg_dep='media-sound/pulseaudio'
			;;
			('sdl1.2')
				pkg_dep="media-libs/libsdl$architecture_suffix"
			;;
			('sdl2')
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
			('vorbis')
				pkg_dep="media-libs/libvorbis$architecture_suffix"
			;;
			('wine')
				use_archive_specific_value "${pkg}_ARCH"
				architecture="$(get_value "${pkg}_ARCH")"
				case "$architecture" in
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
				use_archive_specific_value "${pkg}_ARCH"
				architecture="$(get_value "${pkg}_ARCH")"
				case "$architecture" in
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
			(*)
				pkg_dep="$(gentoo_get_pkg_providers "$dep" | sed -e 's/-/_/g' -e 's|^|games-playit/|')"
				if [ -z "$pkg_dep" ]; then
					pkg_dep='games-playit/'"$(printf '%s' "$dep" | sed 's/-/_/g')"
				else
					pkg_dep="|| ( $pkg_dep )"
				fi
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
# CALLS: pkg_print
# CALLED BY: build_pkg
pkg_build_gentoo() {
	pkg_id="$(get_value "${pkg}_ID" | sed 's/-/_/g')" # This makes sure numbers in the package name doesn't get interpreted as a version by portage

	local pkg_filename_base="$pkg_id-$PKG_VERSION.tbz2"
	for package in $PACKAGES_LIST; do
		if [ "$package" != "$pkg" ] && [ "$(get_value "${package}_ID" | sed 's/-/_/g')" = "$pkg_id" ]; then
			set_architecture "$pkg"
			[ -d "$PWD/$pkg_architecture" ] || mkdir "$PWD/$pkg_architecture"
			pkg_filename_base="$pkg_architecture/$pkg_filename_base"
		fi
	done
	local pkg_filename="$PWD/$pkg_filename_base"

	if [ -e "$pkg_filename" ]; then
		pkg_build_print_already_exists "$pkg_filename_base"
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg}_PKG
		return 0
	fi

	pkg_print "$pkg_filename_base"
	if [ "$DRY_RUN" = '1' ]; then
		printf '\n'
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg}_PKG
		return 0
	fi

	mkdir --parents "$PLAYIT_WORKDIR/portage-tmpdir"
	local ebuild_path="$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/$pkg_id/$pkg_id-$PKG_VERSION.ebuild"
	ebuild "$ebuild_path" manifest 1>/dev/null
	PORTAGE_TMPDIR="$PLAYIT_WORKDIR/portage-tmpdir" PKGDIR="$PLAYIT_WORKDIR/gentoo-pkgdir" BINPKG_COMPRESS="$OPTION_COMPRESSION" fakeroot-ng -- ebuild "$ebuild_path" package 1>/dev/null
	mv "$PLAYIT_WORKDIR/gentoo-pkgdir/games-playit/$pkg_id-$PKG_VERSION.tbz2" "$pkg_filename"
	rm --recursive "$PLAYIT_WORKDIR/portage-tmpdir"

	eval ${pkg}_PKG=\"$pkg_filename\"
	export ${pkg}_PKG

	print_ok
}

