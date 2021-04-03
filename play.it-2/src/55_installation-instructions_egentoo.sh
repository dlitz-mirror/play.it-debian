# print installation instructions for Gentoo Linux with ebuilds
# USAGE: print_instructions_egentoo $pkg[…]
print_instructions_egentoo() {
	local pkg_path
	local ebuild_path
	local distdir_path
	local str_format

	distdir_path=$(get_distdir_gentoo)

	for pkg in "$@"; do
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${PACKAGES_LIST##*$pkg*}" ]; then
			warning_skip_package 'print_instructions_egentoo' "$pkg"
			return 0
		fi
		pkg_path=$(realpath "$(get_value "${pkg}_PKG")")
		ebuild_path="$(basename "${pkg_path%%.*}").ebuild"

		printf 'Move %s to %s.\n' "${pkg_path}" "${distdir_path}"
		printf 'Move %s to games-playit/%s in your local overlay\n' \
			"${ebuild_path}" "$(basename "${ebuild_path}")"
		#TODO Add command to generate ebuild manifests
		printf 'Run: `emerge games-playit/%s`\n' "$(basename "${ebuild_path}")"
	done
}

