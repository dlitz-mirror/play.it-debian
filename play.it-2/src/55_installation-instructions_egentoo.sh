# print installation instructions for Gentoo Linux with ebuilds
# USAGE: print_instructions_egentoo $pkg[…]
print_instructions_egentoo() {
	local pkg_path
	local ebuild_path
	local pkg_id

	info_package_to_distfiles

	for pkg in "$@"; do
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${PACKAGES_LIST##*$pkg*}" ]; then
			warning_skip_package 'print_instructions_egentoo' "$pkg"
			return 0
		fi
		pkg_path=$(realpath "$(get_value "${pkg}_PKG")")
		ebuild_path="$(basename "${pkg_path%%.*}").ebuild"
		pkg_id="$(package_get_id "$pkg")"

		printf 'mkdir -p ${OVERLAY_PATH}/games-playit/%s\n' "${pkg_id}"
		printf 'mv %s ${OVERLAY_PATH}/games-playit/%s/\n' \
			"${ebuild_path}" "${pkg_id}"
		printf 'ebuild ${OVERLAY_PATH}/games-playit/%s/%s manifest\n' \
			"${pkg_id}" "${ebuild_path}"
		printf 'emerge games-playit/%s\n' "${pkg_id}"
	done
}

