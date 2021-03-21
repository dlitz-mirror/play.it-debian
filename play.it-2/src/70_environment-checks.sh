# check that the target directory is on a case-sensitive filesystem
# USAGE: check_directory_is_case_sensitive $tested_directory
# RETURNS: 0 if case-sensitive, 1 if case-insensitive
check_directory_is_case_sensitive() {
	# the first argument should be a writable directory
	# shellcheck disable=SC2039
	local tested_directory
	tested_directory="$1"
	if [ ! -d "$tested_directory" ]; then
		error_not_a_directory "$tested_directory"
		return 1
	fi
	if [ ! -w "$tested_directory" ]; then
		error_not_writable "$tested_directory"
		return 1
	fi

	# check if "a" and "A" are created as distinct files, or as a single one
	# tests are done in an inner temporary directory to avoid messing up with existing files
	# shellcheck disable=SC2039
	local inner_temp_directory
	inner_temp_directory=$(mktemp --directory --tmpdir="$tested_directory")
	touch "${inner_temp_directory}/a"
	touch "${inner_temp_directory}/A"
	# shellcheck disable=SC2039
	local files_count
	files_count=$(find "$inner_temp_directory" -mindepth 1 -maxdepth 1 -iname a | wc --lines)
	rm --recursive "$inner_temp_directory"

	# if "a" and "A" were created as distinct files, the file system is case-sensitive
	# if they were created as a single file, it is case-insensitive
	case "$files_count" in
		(1)
			return 1
		;;
		(2)
			return 0
		;;
		(*)
			# we did not get an expected numeric value (1 or 2), let us assume we do not want to work with this directory
			# it might be better to actually throw some kind of explicit error with a message here
			return 1
		;;
	esac
}

# check that the target directory is on a filesystem supporting UNIX permissions
# USAGE: check_directory_supports_unix_permissions $tested_directory
# RETURNS: 0 if has support for UNIX permissions, 1 if has no support for UNIX permissions
check_directory_supports_unix_permissions() {
	# the first argument should be a writable directory
	# shellcheck disable=SC2039
	local tested_directory
	tested_directory="$1"
	if [ ! -d "$tested_directory" ]; then
		error_not_a_directory "$tested_directory"
		return 1
	fi
	if [ ! -w "$tested_directory" ]; then
		error_not_writable "$tested_directory"
		return 1
	fi

	# change permissions on a file, and check it has an actual effect
	# tests are done in an inner temporary directory to avoid messing up with existing files
	# shellcheck disable=SC2039
	local inner_temp_directory tested_temp_file
	inner_temp_directory=$(mktemp --directory --tmpdir="$tested_directory")
	tested_temp_file="${inner_temp_directory}/a"
	touch "$tested_temp_file"
	# shellcheck disable=SC2039
	local file_permissions
	for file_permissions in '600' '700'; do
		set +o errexit
		chmod "$file_permissions" "$tested_temp_file" 2>/dev/null
		set -o errexit
		if [ "$(stat --printf='%a' "$tested_temp_file")" != "$file_permissions" ]; then
			return 1
		fi
	done
	rm --recursive "$inner_temp_directory"
	return 0
}

