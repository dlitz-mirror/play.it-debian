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

