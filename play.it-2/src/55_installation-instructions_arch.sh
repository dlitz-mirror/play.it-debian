# print installation instructions for Arch Linux
# USAGE: print_instructions_arch $pkg[…]
print_instructions_arch() {
	local pkg_path
	local str_format
	printf 'pacman -U'

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	for pkg in "$@"; do
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${packages_list##*$pkg*}" ]; then
			warning_skip_package 'print_instructions_arch' "$pkg"
			return 0
		fi
		pkg_path=$(realpath "$(get_value "${pkg}_PKG")")
		if [ -z "${pkg_path##* *}" ]; then
			str_format=' "%s"'
		else
			str_format=' %s'
		fi
		printf "$str_format" "$pkg_path"
	done
	printf '\n'
}

