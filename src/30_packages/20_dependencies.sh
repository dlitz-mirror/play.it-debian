# Print the list of native libraries required by a given package
# USAGE: dependencies_list_native_libraries $package
# RETURNS: a list of native library names,
#          one per line
dependencies_list_native_libraries() {
	local package
	package="$1"

	get_value "${package}_DEPENDENCIES_LIBRARIES"
}

# Print the list of native packages providing the native libraries required by a given package
# USAGE: dependencies_list_native_libraries_packages $package
# RETURNS: a list of native package names,
#          one per line
dependencies_list_native_libraries_packages() {
	local package package_architecture
	package="$1"
	package_architecture=$(package_get_architecture "$package")

	local required_native_libraries library
	required_native_libraries=$(dependencies_list_native_libraries "$package")
	for library in $required_native_libraries; do
		case "$OPTION_PACKAGE" in
			('arch')
				case "$package_architecture" in
					('32')
						dependency_package_providing_library_arch32 "$library"
					;;
					(*)
						dependency_package_providing_library_arch "$library"
					;;
				esac
			;;
			('deb')
				dependency_package_providing_library_deb "$library"
			;;
			('gentoo'|'egentoo')
				case "$package_architecture" in
					('32')
						dependency_package_providing_library_gentoo32 "$library"
					;;
					(*)
						dependency_package_providing_library_gentoo "$library"
					;;
				esac
			;;
		esac
		printf '\n'
	done | sort --unique
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

	# Display the list of unkown libraries,
	# skipping duplicates and empty entries.
	sort --unique "$unknown_libraries_list" | \
		grep --invert-match --regexp='^$'
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
