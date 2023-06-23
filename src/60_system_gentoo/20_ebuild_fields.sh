# display keywords of an ebuild made of several packages
# USAGE: egentoo_field_keywords $package…
egentoo_field_keywords() {
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

# Gentoo - Print "RDEPEND" field
# USAGE: package_gentoo_field_rdepend $package
package_gentoo_field_rdepend() {
	local package
	package="$1"

	local dependencies_list first_item_displayed dependency_string
	dependencies_list=$(dependencies_gentoo_full_list "$package")
	first_item_displayed=0
	while IFS= read -r dependency_string; do
		if [ -z "$dependency_string" ]; then
			continue
		fi
		# Gentoo policy is that dependencies should be displayed one per line,
		# and indentation is to be done using tabulations.
		if [ "$first_item_displayed" -eq 0 ]; then
			printf '%s' "$dependency_string"
			first_item_displayed=1
		else
			printf '\n\t%s' "$dependency_string"
		fi
	done <<- EOL
	$(printf '%s' "$dependencies_list")
	EOL

	# Return early when building package in the "egentoo" format,
	# as we have no good way to set conflicts with this format.
	local option_package
	option_package=$(option_value 'package')
	if [ "$option_package" = 'egentoo' ]; then
		return 0
	fi

	local package_conflicts package_conflict
	package_conflicts=$(package_provides "$package")

	# Return early if the current package has no "provides" field.
	if [ -z "$package_conflicts" ]; then
		return 0
	fi

	# Gentoo has no notion of "provided" package,
	# so we need to loop over all supported archives
	# to get the name of all packages providing a given package id.
	local packages_list package_current package_current_id package_current_provides package_current_provide
	packages_list=$(packages_list_all_archives)
	# For each conflict of the current package,
	# find all potential packages that would provide this package id.
	for package_conflict in $package_conflicts; do
		for package_current in $packages_list; do
			# Skip the package we are writing metadata for,
			# so it does not end up conflicting with itself.
			if [ "$package_current" = "$package" ]; then
				continue
			fi
			package_current_provides=$(package_provides "$package_current")
			for package_current_provide in $package_current_provides; do
				if [ "$package_current_provide" = "$package_conflict" ]; then
					package_current_id=$(package_id "$package_current")
					if [ "$first_item_displayed" -eq 0 ]; then
						printf '!games-play.it/%s' "$package_current_id"
						first_item_displayed=1
					else
						printf '\n\t!games-play.it/%s' "$package_current_id"
					fi
				fi
			done
		done
	done
}
