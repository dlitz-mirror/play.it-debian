# Print the list of native libraries required by a given package
# USAGE: dependencies_list_native_libraries $package
# RETURNS: a list of native library names,
#          one per line
dependencies_list_native_libraries() {
	local package
	package="$1"
	assert_not_empty 'package' 'dependencies_list_native_libraries'

	# Distinct dependencies lists might be used based on source archive
	local dependencies_libraries
	dependencies_libraries=$(context_value "${package}_DEPENDENCIES_LIBRARIES")

	# Always return a list with no duplicate entry,
	# excluding empty lines.
	# Ignore grep error return if there is nothing to print.
	printf '%s' "$dependencies_libraries" | \
		sort --unique | \
		grep --invert-match --regexp='^$' || true
}

# Print the list of native packages providing the native libraries required by a given package
# USAGE: dependencies_list_native_libraries_packages $package
# RETURNS: a list of native package names,
#          one per line
dependencies_list_native_libraries_packages() {
	local package
	package="$1"

	local required_native_libraries option_package
	required_native_libraries=$(dependencies_list_native_libraries "$package")
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			local package_architecture
			package_architecture=$(package_architecture "$package")
			case "$package_architecture" in
				('32')
					archlinux_dependencies_providing_native_libraries_32bit $required_native_libraries
				;;
				(*)
					archlinux_dependencies_providing_native_libraries $required_native_libraries
				;;
			esac
		;;
		('deb')
			debian_dependencies_providing_native_libraries $required_native_libraries
		;;
		('gentoo'|'egentoo')
			local package_architecture
			package_architecture=$(package_architecture "$package")
			case "$package_architecture" in
				('32')
					gentoo_dependencies_providing_native_libraries_32bit "$package" $required_native_libraries
				;;
				(*)
					gentoo_dependencies_providing_native_libraries "$package" $required_native_libraries
				;;
			esac
		;;
	esac
}

# Print the path to a temporary files used for unknown libraries listing
# USAGE: dependencies_unknown_libraries_file
dependencies_unknown_libraries_file() {
	printf '%s/unknown_libraries_list' "$PLAYIT_WORKDIR"
}

# Print a list of unknown libraries
# USAGE: dependencies_unknown_libraries_list
dependencies_unknown_libraries_list() {
	local unknown_library unknown_libraries_list
	unknown_libraries_list=$(dependencies_unknown_libraries_file)

	# Return early if there is no unknown library
	if [ ! -e "$unknown_libraries_list" ]; then
		return 0
	fi

	# Display the list of unknown libraries,
	# skipping duplicates and empty entries.
	sort --unique "$unknown_libraries_list" | \
		grep --invert-match --regexp='^$'
}

# Clear the list of unknown libraries
# USAGE: dependencies_unknown_libraries_clear
dependencies_unknown_libraries_clear() {
	local unknown_library unknown_libraries_list
	unknown_libraries_list=$(dependencies_unknown_libraries_file)

	rm --force "$unknown_libraries_list"
}

# Add a library to the list of unknown ones
# USAGE: dependencies_unknown_libraries_add $unknown_library
dependencies_unknown_libraries_add() {
	local unknown_library unknown_libraries_list
	unknown_library="$1"
	unknown_libraries_list=$(dependencies_unknown_libraries_file)

	# Do nothing if this library is already included in the list
	if \
		[ -e "$unknown_libraries_list" ] \
		&& grep --quiet --fixed-strings --word-regexp "$unknown_library" "$unknown_libraries_list"
	then
		return 0
	fi

	printf '%s\n' "$unknown_library" >> "$unknown_libraries_list"
}

# Add a depdendency to the list of the given package.
# This function is used to update the native libraries dependencies list.
# USAGE: dependencies_add_native_libraries $package $dependency
dependencies_add_native_libraries() {
	local package dependency
	package="$1"
	dependency="$2"

	local current_dependencies
	current_dependencies=$(dependencies_list_native_libraries "$package")

	local dependencies_variable_name
	dependencies_variable_name=$(context_name "${package}_DEPENDENCIES_LIBRARIES")
	if [ -z "$dependencies_variable_name" ]; then
		dependencies_variable_name="${package}_DEPENDENCIES_LIBRARIES"
	fi
	export $dependencies_variable_name="$current_dependencies
	$dependency"
}
