# set temporary directories
# USAGE: set_temp_directories $pkg[…]
set_temp_directories() {
	local base_directory

	debug_entering_function 'set_temp_directories'

	# If $PLAYIT_WORKDIR is already set, delete it before setting a new one
	[ "$PLAYIT_WORKDIR" ] && rm --force --recursive "$PLAYIT_WORKDIR"

	# Look for a directory with enough free space to work in
	base_directory=$(temporary_directories_find_base)

	# Generate a directory with a unique name for the current instance
	PLAYIT_WORKDIR="$(mktemp --directory --tmpdir="$base_directory" "$(game_id).XXXXX")"
	debug_option_value 'PLAYIT_WORKDIR'
	debug_creating_directory "$PLAYIT_WORKDIR"
	export PLAYIT_WORKDIR

	# Set $postinst and $prerm
	mkdir --parents "$PLAYIT_WORKDIR/scripts"
	postinst="$PLAYIT_WORKDIR/scripts/postinst"
	export postinst
	prerm="$PLAYIT_WORKDIR/scripts/prerm"
	export prerm

	# Export the path to the packages to build as PKG_xxx_PATH
	# Some game scripts are expecting this variable to be set
	# These should be updated to call `package_get_path` instead
	local package package_path
	for package in "$@"; do
		testvar "$package" 'PKG'
		package_path=$(package_get_path "$package")
		eval "${package}_PATH='${package_path}'"
		export "${package?}_PATH"
	done

	debug_leaving_function 'set_temp_directories'
}

# get available temporary directories list
# For now this list is hardcoded, but might be read in the future from a
# configuration file
# USAGE: temporary_directories_list_candidates
# RETURNS: a list of candidate directories to create ./play.it temporary work directory in,
#          separated by line breaks
temporary_directories_list_candidates() {
	printf '%s\n' \
		"$(realpath "${TMPDIR:-/tmp}")" \
		"${XDG_CACHE_HOME:=$HOME/.cache}" \
		"$PWD"
	return 0
}

# find a temp directory with enough free space to work in
# USAGE: temporary_directories_find_base
# RETURNS: the path to a directory with enough free space to use for ./play.it temporary files
temporary_directories_find_base() {
	debug_entering_function 'temporary_directories_find_base' 2

	local base_directory candidate_directory
	if [ "$NO_FREE_SPACE_CHECK" -eq 0 ]; then
		local free_space_required free_space_available
		###
		# TODO
		# The required free space should be returned by a dedicated function,
		# instead of relying on a global variable.
		###
		# Fail early if the required free space for the current archive is not computable
		if [ -z "$ARCHIVE_SIZE" ]; then
			error_variable_not_set 'temporary_directories_find_base' 'ARCHIVE_SIZE'
			return 1
		fi
		free_space_required=$((ARCHIVE_SIZE * 2))
	fi

	# Scan candidate directories to find one with enough free space to use for storing temporary files
	while read -r candidate_directory
	do
		if [ ! -d "$candidate_directory" ]; then
			debug_temp_dir_nonexistant "$candidate_directory"
			continue
		fi
		if [ ! -w "$candidate_directory" ]; then
			debug_temp_dir_nonwritable "$candidate_directory"
			continue
		fi
		# Check that the candidate temporary directory is on a case-sensitive filesystem
		if ! check_directory_is_case_sensitive "$candidate_directory"; then
			debug_temp_dir_case_insensitive_not_supported "$candidate_directory"
			continue
		fi
		# Check that the candidate temporary directory is on a filesystem with
		# support for UNIX permissions
		if ! check_directory_supports_unix_permissions "$candidate_directory"; then
			debug_temp_dir_no_unix_permissions "$candidate_directory"
			continue
		fi
		if [ "$NO_FREE_SPACE_CHECK" -eq 0 ]; then
			free_space_available=$(LANG=C df \
				--block-size=1K \
				--output=avail \
				"$candidate_directory" 2>/dev/null | \
				tail --lines=1)
			if [ "$free_space_available" -lt "$free_space_required" ]; then
				debug_temp_dir_not_enough_space "$candidate_directory"
				continue
			fi
		fi
		base_directory=$(temporary_directories_full_path "$candidate_directory")
		break;
	done <<- EOF
	$(temporary_directories_list_candidates)
	EOF

	# Fail with an explicit error if no valid candidate has been found
	if [ -z "$base_directory" ]; then
		# shellcheck disable=SC2046
		error_no_valid_temp_dir_found $(temporary_directories_list_candidates)
		return 1
	fi

	debug_using_directory "$base_directory"
	mkdir --parents "$base_directory"

	printf '%s' "$base_directory"
	debug_leaving_function 'temporary_directories_find_base' 2
	return 0
}

# Get play.it working directory full path
# USAGE: temporary_directories_full_path $parent_dir
# RETURN: the full path to use for ./play.it working directory,
#         it ends with "/play.it" if the parent directory is owned by the current user,
#         or with "/play.it-${USER}" otherwise, where "${USER}" is the current user name
temporary_directories_full_path() {
	local parent_dir
	parent_dir="$1"
	if [ ! -d "$parent_dir" ]; then
		error_not_a_directory "$parent_dir"
		return 1
	fi

	if [ "$(stat -c '%u' "$parent_dir")" -eq "$(id -u)" ]; then
		printf '%s' "$parent_dir/play.it"
	else
		printf '%s' "$parent_dir/play.it-${USER}"
	fi

	return 0
}
