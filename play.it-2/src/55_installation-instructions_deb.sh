# print installation instructions for Debian
# USAGE: print_instructions_deb $pkg[…]
# CALLS: print_instructions_deb_apt print_instructions_deb_dpkg
print_instructions_deb() {
	if command -v apt >/dev/null 2>&1; then
		debian_version=$(LANG=C apt --version 2>/dev/null | \
			grep --extended-regexp --only-matching '[0-9]+(\.[0-9]+)+')
		debian_version_major=$(printf '%s' "$debian_version" | \
			cut --delimiter='.' --fields=1)
		debian_version_minor=$(printf '%s' "$debian_version" | \
			cut --delimiter='.' --fields=2)
		if \
			[ $debian_version_major -ge 2 ] || \
			{
				[ $debian_version_major -eq 1 ] && \
				[ ${debian_version_minor%~*} -ge 1 ]
			}
		then
			print_instructions_deb_apt "$@"
		else
			print_instructions_deb_dpkg "$@"
		fi
	else
		print_instructions_deb_dpkg "$@"
	fi
}

# print installation instructions for Debian with apt
# USAGE: print_instructions_deb_apt $pkg[…]
# CALLS: print_instructions_deb_common
# CALLED BY: print_instructions_deb
print_instructions_deb_apt() {
	printf 'apt install'
	print_instructions_deb_common "$@"
}

# print installation instructions for Debian with dpkg + apt-get
# USAGE: print_instructions_deb_dpkg $pkg[…]
# CALLS: print_instructions_deb_common
# CALLED BY: print_instructions_deb
print_instructions_deb_dpkg() {
	printf 'dpkg -i'
	print_instructions_deb_common "$@"
	printf 'apt-get install -f\n'
}

# print installation instructions for Debian (common part)
# USAGE: print_instructions_deb_common $pkg[…]
# CALLED BY: print_instructions_deb_apt print_instructions_deb_dpkg
print_instructions_deb_common() {
	local pkg_path
	local str_format

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	for pkg in "$@"; do
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${packages_list##*$pkg*}" ]; then
			warning_skip_package 'print_instructions_deb_common' "$pkg"
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

