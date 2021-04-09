# get default temporary dir
# USAGE: get_tmp_dir
get_tmp_dir() {
	local tmpdir

	# Convert TMPDIR to an absolute path before returning it
	tmpdir=$(realpath "${TMPDIR:-/tmp}")

	printf '%s' "$tmpdir"
	return 0
}

# set temporary directories
# USAGE: set_temp_directories $pkg[…]
# NEEDED VARS: (ARCHIVE_SIZE) GAME_ID (LANG) (PWD) (XDG_CACHE_HOME) (XDG_RUNTIME_DIR)
# CALLS: testvar get_tmp_dir
set_temp_directories() {
	local free_space
	local needed_space
	local tmpdir

	# If $PLAYIT_WORKDIR is already set, delete it before setting a new one
	[ "$PLAYIT_WORKDIR" ] && rm --force --recursive "$PLAYIT_WORKDIR"

	# Look for a directory with enough free space to work in
	# shellcheck disable=SC2039
	local base_directory
	unset base_directory
	tmpdir="$(get_tmp_dir)"
	if [ "$NO_FREE_SPACE_CHECK" -eq 1 ]; then
		base_directory="$tmpdir/play.it"
		mkdir --parents "$base_directory"
		chmod 777 "$base_directory"
	else
		if [ "$ARCHIVE_SIZE" ]; then
			needed_space=$((ARCHIVE_SIZE * 2))
		else
			error_variable_not_set 'set_temp_directories' '$ARCHIVE_SIZE'
		fi
		[ "$XDG_CACHE_HOME" ]  || XDG_CACHE_HOME="$HOME/.cache"
		for directory in \
			"$tmpdir" \
			"$XDG_CACHE_HOME" \
			"$PWD"
		do
			free_space=$(df --output=avail "$directory" 2>/dev/null | tail --lines=1)
			if [ -w "$directory" ] && [ $free_space -ge $needed_space ]; then
				base_directory="$directory/play.it"
				if [ "$directory" = "$tmpdir" ]; then
					if [ ! -e "$base_directory" ]; then
						mkdir --parents "$base_directory"
						chmod 777 "$base_directory"
					fi
				fi
				break;
			fi
		done
		if [ -n "$base_directory" ]; then
			mkdir --parents "$base_directory"
		else
			error_not_enough_free_space \
				"$tmpdir" \
				"$XDG_CACHE_HOME" \
				"$PWD"
		fi
	fi

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
}

