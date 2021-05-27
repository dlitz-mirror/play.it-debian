# set temporary directories
# USAGE: set_temp_directories $pkg[…]
# NEEDED VARS: (ARCHIVE_SIZE) GAME_ID (LANG) (PWD) (XDG_CACHE_HOME) (XDG_RUNTIME_DIR)
# CALLS: testvar temporary_directories_find_base check_directory_is_case_sensitive
#	check_directory_supports_unix_permissions
# SETS: PLAYIT_WORKDIR postinst prerm
set_temp_directories() {
	local base_directory

	debug_entering_function 'set_temp_directories'

	# If $PLAYIT_WORKDIR is already set, delete it before setting a new one
	[ "$PLAYIT_WORKDIR" ] && rm --force --recursive "$PLAYIT_WORKDIR"

	# Look for a directory with enough free space to work in
	# shellcheck disable=SC2039
	base_directory=$(temporary_directories_find_base)

	# Check that the candidate temporary directory is on a case-sensitive filesystem
	if ! check_directory_is_case_sensitive "$base_directory"; then
		error_case_insensitive_filesystem_is_not_supported "$base_directory"
		return 1
	fi

	# Check that the candidate temporary directory is on a filesystem with support for UNIX permissions
	if ! check_directory_supports_unix_permissions "$base_directory"; then
		error_unix_permissions_support_is_required "$base_directory"
		return 1
	fi

	# Generate a directory with a unique name for the current instance
	PLAYIT_WORKDIR="$(mktemp --directory --tmpdir="$base_directory" "${GAME_ID}.XXXXX")"
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
	# shellcheck disable=SC2039
	local package
	for package in "$@"; do
		testvar "$package" 'PKG'
		eval "${package}_PATH='$(package_get_path "$package")'"
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

	# shellcheck disable=SC2039
	local base_directory
	if [ $NO_FREE_SPACE_CHECK -eq 1 ]; then
		# If free space check has been explicitely disabled,
		# use the first directory returned by temporary_directories_list_candidates
		# shellcheck disable=SC2039
		local default_directory
		default_directory="$(temporary_directories_list_candidates | head --lines=1)"
		base_directory=$(temporary_directories_full_path "$default_directory")
	else
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

		# Scan candidate directories to find one with enough free space to use for storing temporary files
		# shellcheck disable=SC2039
		local free_space_required free_space_available candidate_directory
		free_space_required=$((ARCHIVE_SIZE * 2))
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
			free_space_available=$(LANG=C df \
				--block-size=1K \
				--output=avail \
				"$candidate_directory" 2>/dev/null | \
				tail --lines=1)
			if [ $free_space_available -ge $free_space_required ]; then
				base_directory=$(temporary_directories_full_path "$candidate_directory")
				break;
			fi
			debug_temp_dir_not_enough_space "$candidate_directory"
		done <<- EOF
		$(temporary_directories_list_candidates)
		EOF

		# Fail with an explicit error if no valid candidate has been found
		if [ -z "$base_directory" ]; then
			# shellcheck disable=SC2046
			error_not_enough_free_space $(temporary_directories_list_candidates)
			return 1
		fi
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
	# shellcheck disable=SC2039
	local parent_dir
	parent_dir="$1"
	if [ ! -d "$parent_dir" ]; then
		error_not_a_directory "$parent_dir"
	fi

	if [ "$(stat -c '%u' "$parent_dir")" -eq "$(id -u)" ]; then
		printf '%s' "$parent_dir/play.it"
	else
		printf '%s' "$parent_dir/play.it-${USER}"
	fi

	return 0
}
