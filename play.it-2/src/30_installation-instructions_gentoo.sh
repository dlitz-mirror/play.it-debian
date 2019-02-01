# print installation instructions for Gentoo Linux
# USAGE: print_instructions_gentoo $pkg[…]
print_instructions_gentoo() {
	local pkg_path
	local str_format
	local str_comment
	printf 'quickunpkg --'
	for pkg in "$@"; do
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${PACKAGES_LIST##*$pkg*}" ]; then
			skipping_pkg_warning 'print_instructions_gentoo' "$pkg"
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
	case "${LANG%_*}" in
		('fr')
			str_comment='ou mettez les paquets dans un PKGDIR (dans un dossier nommé games-playit) et emergez-les'
		;;
		('en'|*)
			str_comment='or put the packages in a PKGDIR (in a folder named games-playit) and emerge them'
		;;
	esac
	printf ' # %s %s\n' 'https://www.dotslashplay.it/ressources/gentoo/' "$str_comment"
}

