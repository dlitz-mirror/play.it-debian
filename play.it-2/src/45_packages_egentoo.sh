# write .ebuild package meta-data
# USAGE: pkg_write_egentoo
# NEEDED VARS: GAME_NAME PKG_DEPS_GENTOO
# CALLED BY: write_metadata
pkg_write_egentoo() {
	local pkg_deps
	local ebuild_path
	local pkg_architectures

	use_archive_specific_value "${pkg}_DEPS"
	if [ "$(get_value "${pkg}_DEPS")" ]; then
		#shellcheck disable=SC2046
		pkg_set_deps_gentoo $(get_value "${pkg}_DEPS")
	fi
	use_archive_specific_value "${pkg}_DEPS_GENTOO"
	if [ "$(get_value "${pkg}_DEPS_GENTOO")" ]; then
		pkg_deps="$pkg_deps $(get_value "${pkg}_DEPS_GENTOO")"
	fi
	if [ -n "$(package_get_provide "$pkg")" ]; then
		pkg_deps="${pkg_deps} $(package_get_provide "$pkg")"
	fi

	ebuild_path="$PLAYIT_WORKDIR/$pkg/$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").ebuild"

	cat > "$ebuild_path" <<- EOF
	EAPI=7
	RESTRICT="fetch strip binchecks"
	EOF
}
