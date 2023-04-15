# Print the list of Mono libraries required by a given package
# USAGE: dependencies_list_mono_libraries $package
# RETURNS: a list of Mono library names,
#          one per line
dependencies_list_mono_libraries() {
	local package
	package="$1"

	# Distinct dependencies lists might be used based on source archive
	local dependencies_mono_libraries
	dependencies_mono_libraries=$(context_value "${package}_DEPENDENCIES_MONO_LIBRARIES")

	# Always return a list with no duplicate entry,
	# excluding empty lines.
	# Ignore grep error return if there is nothing to print.
	printf '%s' "$dependencies_mono_libraries" | \
		sort --unique | \
		grep --invert-match --regexp='^$' || true
}

# Print the list of native packages providing the Mono libraries required by a given package
# USAGE: dependencies_list_mono_libraries_packages $package
# RETURNS: a list of native package names,
#          one per line
dependencies_list_mono_libraries_packages() {
	local package
	package="$1"

	# Return early if the current package requires no Mono library
	local required_mono_libraries library
	required_mono_libraries=$(dependencies_list_mono_libraries "$package")
	if [ -z "$required_mono_libraries" ]; then
		return 0
	fi

	# Return early when building packages for a system that does not provide Mono libraries in dedicated packages.
	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			# Arch Linux provides all Mono libraries in a single "mono" package.
			printf '%s\n' 'mono'
			return 0
		;;
		('gentoo'|'egentoo')
			# Gentoo provides all Mono libraries in a single "dev-lang/mono" package.
			printf '%s\n' 'dev-lang/mono'
			return 0
		;;
	esac

	case "$option_package" in
		('deb')
			debian_dependencies_providing_mono_libraries $required_mono_libraries
			return 0
		;;
	esac
}

# Print the path to a temporary files used for unknown Mono libraries listing
# USAGE: dependencies_unknown_mono_libraries_file
dependencies_unknown_mono_libraries_file() {
	printf '%s/unknown_mono_libraries_list' "$PLAYIT_WORKDIR"
}

# Print a list of unknown Mono libraries
# USAGE: dependencies_unknown_mono_libraries_list
dependencies_unknown_mono_libraries_list() {
	local unknown_library unknown_libraries_list
	unknown_libraries_list=$(dependencies_unknown_mono_libraries_file)

	# Return early if there is no unknown library
	if [ ! -e "$unknown_libraries_list" ]; then
		return 0
	fi

	# Display the list of unknown libraries,
	# skipping duplicates and empty entries.
	sort --unique "$unknown_libraries_list" | \
		grep --invert-match --regexp='^$'
}

# Clear the list of unknown Mono libraries
# USAGE: dependencies_unknown_mono_libraries_clear
dependencies_unknown_mono_libraries_clear() {
	local unknown_library unknown_libraries_list
	unknown_libraries_list=$(dependencies_unknown_mono_libraries_file)

	rm --force "$unknown_libraries_list"
}

# Add a Mono library to the list of unknown ones
# USAGE: dependencies_unknown_mono_libraries_add $unknown_library
dependencies_unknown_mono_libraries_add() {
	local unknown_library unknown_libraries_list
	unknown_library="$1"
	unknown_libraries_list=$(dependencies_unknown_mono_libraries_file)

	# Do nothing if this library is already included in the list
	if \
		[ -e "$unknown_libraries_list" ] \
		&& grep --quiet --fixed-strings --word-regexp "$unknown_library" "$unknown_libraries_list"
	then
		return 0
	fi

	printf '%s\n' "$unknown_library" >> "$unknown_libraries_list"
}
