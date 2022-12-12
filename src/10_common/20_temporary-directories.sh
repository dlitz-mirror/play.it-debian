# set temporary directories
# USAGE: set_temp_directories
set_temp_directories() {
	debug_entering_function 'set_temp_directories'

	# Get path to temporary directory
	local temporary_directory_path
	temporary_directory_path=$(temporary_directory_path)

	# Check that the given path is valid for temporary files storage
	temporary_directory_checks "$temporary_directory_path"

	# Generate a directory with a unique name for the current instance
	local game_id
	game_id=$(game_id)
	PLAYIT_WORKDIR=$(mktemp --directory --tmpdir="$temporary_directory_path" "${game_id}.XXXXX")
	debug_option_value 'PLAYIT_WORKDIR'
	debug_creating_directory "$PLAYIT_WORKDIR"
	export PLAYIT_WORKDIR

	# Export the path to the packages to build as PKG_xxx_PATH
	# Some game scripts are expecting this variable to be set
	# These should be updated to call `package_get_path` instead
	local packages_list package package_path
	packages_list=$(packages_get_list)
	for package in $packages_list; do
		testvar "$package" 'PKG'
		package_path=$(package_get_path "$package")
		eval "${package}_PATH='${package_path}'"
		export "${package?}_PATH"
	done

	debug_leaving_function 'set_temp_directories'
}

# Print the path to the temporary directory to use
# USAGE: temporary_directory_path
temporary_directory_path() {
	# Use the value set through --tmpdir if it is set
	if ! variable_is_empty 'OPTION_TMPDIR'; then
		printf '%s' "$OPTION_TMPDIR"
		return 0
	fi

	# Fall back to using $TMPDIR, defaulting to /tmp
	printf '%s' "${TMPDIR:-/tmp}"
}

# Run checks on the path used for temporary files
# USAGE: temporary_directory_checks $temporary_directory_path
temporary_directory_checks() {
	local temporary_directory_path
	temporary_directory_path="$1"

	# Check that the given path is an existing directory
	if [ ! -d "$temporary_directory_path" ]; then
		error_temporary_path_not_a_directory "$temporary_directory_path"
		return 1
	fi

	# Check that the given path is writable
	if [ ! -w "$temporary_directory_path" ]; then
		error_temporary_path_not_writable "$temporary_directory_path"
		return 1
	fi

	# Check that the given path is on a case-sensitive filesystem
	if ! check_directory_is_case_sensitive "$temporary_directory_path"; then
		error_temporary_path_not_case_sensitive "$temporary_directory_path"
		return 1
	fi

	# Check that the given path is on a filesystem with support for UNIX permissions
	if ! check_directory_supports_unix_permissions "$temporary_directory_path"; then
		error_temporary_path_no_unix_permissions "$temporary_directory_path"
		return 1
	fi

	# Check that the given path has allow use of the execution bit
	if ! check_directory_supports_executable_files "$temporary_directory_path"; then
		error_temporary_path_noexec "$temporary_directory_path"
		return 1
	fi

	# Check that there is enough free space under the given path
	if [ "$NO_FREE_SPACE_CHECK" -eq 0 ]; then
		local free_space_required free_space_available
		###
		# TODO
		# The required free space should be returned by a dedicated function,
		# instead of relying on a global variable.
		###
		# Fail early if the required free space for the current archive is not computable
		assert_not_empty 'ARCHIVE_SIZE' 'temporary_directory_checks'

		free_space_required=$((ARCHIVE_SIZE * 2))
		free_space_available=$(LANG=C df \
			--block-size=1K \
			--output=avail \
			"$temporary_directory_path" 2>/dev/null | \
			tail --lines=1)
		if [ "$free_space_available" -lt "$free_space_required" ]; then
			error_temporary_path_not_enough_space "$temporary_directory_path"
			return 1
		fi
	fi
}
