# check that the target directory is on a case-sensitive filesystem
# USAGE: check_directory_is_case_sensitive $tested_directory
# RETURNS: 0 if case-sensitive, 1 if case-insensitive
check_directory_is_case_sensitive() {
	# the first argument should be a writable directory
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
	local inner_temp_directory
	inner_temp_directory=$(mktemp --directory --tmpdir="$tested_directory")
	touch "${inner_temp_directory}/a"
	touch "${inner_temp_directory}/A"
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

	# Change permissions on a file, and check it has an actual effect
	# Tests are done in an inner temporary directory to avoid messing up with existing files
	local inner_temp_directory tested_temp_file file_permissions_expected file_permissions_real
	inner_temp_directory=$(mktemp --directory --tmpdir="$tested_directory")
	tested_temp_file="${inner_temp_directory}/a"
	touch "$tested_temp_file"
	for file_permissions_expected in '600' '700'; do
		chmod "$file_permissions_expected" "$tested_temp_file" 2>/dev/null || true
		file_permissions_real=$(stat --printf='%a' "$tested_temp_file")
		if [ "$file_permissions_real" != "$file_permissions_expected" ]; then
			return 1
		fi
	done
	rm --recursive "$inner_temp_directory"
}

# check that the target directory is on a filesystem supporting executable files
# USAGE: check_directory_supports_executable_files $tested_directory
# RETURNS: 0 if has support for executable files, 1 otherwise
check_directory_supports_executable_files() {
	local tested_directory
	tested_directory="$1"
	if [ ! -d "$tested_directory" ]; then
		error_not_a_directory "$tested_directory"
		return 1
	fi

	findmnt --first-only --list --options +noexec --target "$tested_directory" >/dev/null
	case $? in
		(0)
			return 1
			;;
		(1)
			return 0
			;;
		(*)
			# Something unexpected happened, we do not want to deal with it
			return 1
			;;
	esac
}

# Compare two version strings using the x.y.z format
# An arbitrary number of numeric fields is supported.
# USAGE: version_is_at_least $version_reference $version_tested
# RETURNS: 0 if bigger or equal, 1 otherwise
version_is_at_least() {
	local version_reference version_tested
	version_reference="$1"
	version_tested="$2"

	if command -v 'dpkg' >/dev/null 2>&1; then
		version_is_at_least_dpkg "$version_reference" "$version_tested"
	else
		version_is_at_least_shell "$version_reference" "$version_tested"
	fi
}

# Compare two version strings using the x.y.z format
# The comparison is done using dpkg.
# USAGE: version_is_at_least_dpkg $version_reference $version_tested
# RETURNS: 0 if bigger or equal, 1 otherwise
version_is_at_least_dpkg() {
	local version_reference version_tested
	version_reference="$1"
	version_tested="$2"

	dpkg --compare-versions "$version_tested" 'ge' "$version_reference"
}

# Compare two version strings using the x.y.z format
# The comparison is implemented in Shell.
# USAGE: version_is_at_least_shell $version_reference $version_tested
# RETURNS: 0 if bigger or equal, 1 otherwise
version_is_at_least_shell() {
	local version_reference version_tested
	version_reference="$1"
	version_tested="$2"

	# If both version strings are the same, return early.
	if [ "$version_tested" = "$version_reference" ]; then
			return 0
	fi

	# Compare version fields one at a time.
	local field field_reference field_tested
	field=1
	field_reference=$(printf '%s' "$version_reference" | cut --delimiter='.' --fields=$field)
	field_tested=$(printf '%s' "$version_tested" | cut --delimiter='.' --fields=$field)
	while [ -n "$field_reference" ] && [ -n "$field_tested" ]; do
		if [ "$field_tested" -lt "$field_reference" ]; then
			return 1
		elif [ "$field_tested" -gt "$field_reference" ]; then
			return 0
		else
			field=$((field + 1))
			field_reference=$(printf '%s' "$version_reference" | cut --delimiter='.' --fields=$field)
			field_tested=$(printf '%s' "$version_tested" | cut --delimiter='.' --fields=$field)
		fi
	done

	# Both version number have a different number of fields,
	# and all compared fields are the same.
	## If the reference is longer, the tested version number is lower.
	if [ -n "$field_reference" ]; then
		return 1
	## If the tested version is longer, it is higher than the reference one.
	elif [ -n "$field_tested" ]; then
		return 0
	fi
}

# assert a variable is not empty and display an error message otherwise
# USAGE: assert_not_empty $variable_name $calling_function
assert_not_empty() {
	local variable_name calling_function
	variable_name="$1"
	calling_function="$2"

	local variable_value
	variable_value=$(get_value "$variable_name")
	if [ -z "$variable_value" ]; then
		error_empty_string "$calling_function" "$variable_name"
		return 1
	fi
}

