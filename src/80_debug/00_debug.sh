# print DEBUG
# USAGE: print_debug
print_debug() {
	printf '\033[1;32mDEBUG:\033[0m ' >> /dev/stderr
	return 0
}

# print an option’s value
# USAGE: debug_option_value $option_name
debug_option_value() {
	if [ "$DEBUG" -eq 0 ]; then
		return 0
	fi

	local option_name
	option_name="$1"
	assert_not_empty 'option_name' 'debug_option_value'

	local option_value
	option_value=$(get_value "$option_name")

	print_debug
	printf '%s: %s\n' "$option_name" "$option_value" >> /dev/stderr
	return 0
}

# print the name of the entered function
# USAGE: debug_entering_function $function_name [$debug_level]
debug_entering_function() {
	local debug_level

	if [ "$#" -eq 2 ]; then
		debug_level="$2"

		case "$debug_level" in
			([0-9]) ;;
			(*)
				error_invalid_argument 'debug_level' 'debug_entering_function'
				return 1
			;;
		esac

	else
		debug_level=1
	fi

	if [ "$DEBUG" -lt "$debug_level" ]; then
		return 0
	fi

	local function_name
	function_name="$1"
	assert_not_empty 'function_name' 'debug_entering_function'

	print_debug
	printf 'Entering %s\n' "$function_name" >> /dev/stderr
	return 0
}

# print the name of the leaved function
# USAGE: debug_leaving_function $function_name [$debug_level]
debug_leaving_function() {
	local debug_level

	if [ "$#" -eq 2 ]; then
		debug_level="$2"

		case "$debug_level" in
			([0-9]) ;;
			(*)
				error_invalid_argument 'debug_level' 'debug_entering_function'
				return 1
			;;
		esac

	else
		debug_level=1
	fi

	if [ "$DEBUG" -lt "$debug_level" ]; then
		return 0
	fi

	local function_name
	function_name="$1"
	assert_not_empty 'function_name' 'debug_leaving_function'

	print_debug
	printf 'Leaving %s\n' "$function_name" >> /dev/stderr
	return 0
}

# print the name of the created directory
# USAGE: debug_creating_directory $dir_path
debug_creating_directory() {
	if [ "$DEBUG" -eq 0 ]; then
		return 0
	fi

	local dir_path
	dir_path="$1"
	assert_not_empty 'dir_path' 'debug_creating_directory'

	print_debug
	printf 'Creating directory %s\n' "$dir_path" >> /dev/stderr
	return 0
}

# print the name of an used directory
# USAGE: debug_using_directory $dir_path
debug_using_directory() {
	if [ "$DEBUG" -eq 0 ]; then
		return 0
	fi

	local dir_path
	dir_path="$1"
	assert_not_empty 'dir_path' 'debug_using_directory'

	print_debug
	printf 'Using existing directory %s\n' "$dir_path" >> /dev/stderr
	return 0
}

# print the name of a source file found
# USAGE: debug_source_file $filename $source_path $inner_path
debug_source_file() {
	###
	# TODO
	# check number of arguments
	###

	if [ "$DEBUG" -lt 2 ]; then
		return 0
	fi

	local found_status filename
	found_status="$1"
	filename="$2"
	assert_not_empty 'found_status' 'debug_source_file'
	assert_not_empty 'filename' 'debug_source_file'

	print_debug
	printf '%s file: %s\n' "$found_status" "${filename}" >> /dev/stderr
	return 0
}

# print the id of the package a source file is moved to
# intended to be used after debug_source_file
# USAGE: debug_file_to_package $package_id
debug_file_to_package() {
	if [ "$DEBUG" -lt 3 ]; then
		return 0
	fi

	local package_id
	package_id="$1"
	assert_not_empty 'package_id' 'debug_file_to_package'

	print_debug
	printf 'Moving file to: %s\n' "$package_id" >> /dev/stderr
	return 0
}

# print the type of the launcher being created
# USAGE: debug_write_launcher $launcher_type
debug_write_launcher() {
	if [ "$DEBUG" -eq 0 ]; then
		return 0
	fi

	local launcher_type binary_file
	launcher_type="$1"
	binary_file="$2"
	assert_not_empty 'launcher_type' 'debug_write_launcher'

	print_debug
	if [ -z "$binary_file" ]; then
		printf 'Writing launcher: %s\n' "$launcher_type" >> /dev/stderr
	else
		printf 'Writing %s launcher: %s\n' "$launcher_type" "$binary_file" >> /dev/stderr
	fi
	return 0
}

# print an external command
# USAGE: debug_external_command $command
debug_external_command() {
	if [ "$DEBUG" -eq 0 ]; then
		return 0
	fi

	local external_command
	external_command="$1"
	assert_not_empty 'external_command' 'debug_external_command'

	print_debug
	printf 'Running: %s\n' "$external_command" >> /dev/stderr
	return 0
}
