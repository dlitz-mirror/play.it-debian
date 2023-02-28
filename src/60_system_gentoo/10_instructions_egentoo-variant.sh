# print installation instructions for Gentoo Linux with ebuilds
# USAGE: print_instructions_egentoo $pkg[…]
print_instructions_egentoo() {
	info_package_to_distfiles

	local pkg pkg_path ebuild_path package_id
	for pkg in "$@"; do
		pkg_path=$(realpath "$(get_value "${pkg}_PKG")")
		ebuild_path="$(basename "${pkg_path%%.*}").ebuild"
		package_id=$(package_id "$pkg")

		printf 'mkdir -p ${OVERLAY_PATH}/games-playit/%s\n' \
			"$package_id"
		printf 'mv %s ${OVERLAY_PATH}/games-playit/%s/\n' \
			"$ebuild_path" "$package_id"
		printf 'ebuild ${OVERLAY_PATH}/games-playit/%s/%s manifest\n' \
			"$package_id" "$ebuild_path"
		printf 'emerge games-playit/%s\n' \
			"$package_id"
	done
}

