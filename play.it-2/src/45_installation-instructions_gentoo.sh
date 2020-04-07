# print installation instructions for Gentoo Linux
# USAGE: print_instructions_gentoo $pkg[…]
print_instructions_gentoo() {
	local pkg_path
	local str_format
	printf 'quickunpkg --'
	for pkg in "$@"; do
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${PACKAGES_LIST##*$pkg*}" ]; then
			warning_skip_package 'print_instructions_gentoo' "$pkg"
			return 0
		fi
		pkg_path="$(get_value "${pkg}_PKG")"
		if [ -z "${pkg_path##* *}" ]; then
			str_format=' "%s"'
		else
			str_format=' %s'
		fi
		printf "$str_format" "$pkg_path"
	done
	printf ' # https://downloads.dotslashplay.it/resources/gentoo/ '
	information_installation_instructions_gentoo_comment
	printf '\n'
}

