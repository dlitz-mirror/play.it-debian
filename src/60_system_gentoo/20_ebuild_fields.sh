# display keywords of an ebuild made of several packages
# USAGE: egentoo_field_keywords $package…
egentoo_field_keywords() {
	if [ $# -eq 0 ]; then
		error_no_arguments 'egentoo_field_keywords'
	fi

	local keywords package package_architecture
	keywords='x86 amd64'
	for package in "$@"; do
		package_architecture=$(package_architecture "$package")
		case "$package_architecture" in
			('32')
				printf '%s' '-* x86 amd64'
				return 0
				;;
			('64')
				keywords='-* amd64'
				;;
		esac
	done

	printf '%s' "$keywords"
}

# display egentoo ebuild RDEPEND field
# USAGE: egentoo_field_rdepend $package…
egentoo_field_rdepend() {
	if [ $# -eq 0 ]; then
		error_no_arguments 'egentoo_field_rdepend'
	fi

	local package package_architecture package_64bits package_32bits package_data
	package_64bits=''
	package_32bits=''
	package_data=''
	for package in "$@"; do
		package_architecture=$(package_architecture "$package")
		case "$package_architecture" in
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
