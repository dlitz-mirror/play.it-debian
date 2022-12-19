# display keywords of an ebuild made of several packages
# USAGE: egentoo_field_keywords $package…
egentoo_field_keywords() {
	local keywords
	local package

	if [ $# -eq 0 ]; then
		error_no_arguments 'egentoo_field_keywords'
	fi

	for package in "$@"; do
		case "$(package_get_architecture "$package")" in
			('32')
				printf '%s' '-* x86 amd64'
				return 0
				;;
			('64')
				keywords='-* amd64'
				;;
		esac
	done

	if test -n "$keywords"; then
		printf '%s' "$keywords"
	else
		printf '%s' 'x86 amd64'
	fi
}

# display egentoo ebuild RDEPEND field
# USAGE: egentoo_field_rdepend $package…
egentoo_field_rdepend() {
	local package_64bits
	local package_32bits
	local package_data
	local package

	if [ $# -eq 0 ]; then
		error_no_arguments 'egentoo_field_rdepend'
	fi

	for package in "$@"; do
		case "$(package_get_architecture "$package")" in
			('32')
				package_32bits="$package"
				;;
			('64')
				package_64bits="$package"
				;;
			(*)
				package_data="$package"
				;;
		esac
	done

	if [ -n "$package_64bits" ]; then
		package_gentoo_field_rdepend "$package_64bits"
	elif [ -n "$package_32bits" ]; then
		package_gentoo_field_rdepend "$package_32bits"
	elif [ -n "$package_data" ]; then
		package_gentoo_field_rdepend "$package_data"
	fi
}
