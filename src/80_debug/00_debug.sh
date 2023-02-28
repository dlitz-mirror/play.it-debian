# print DEBUG
# USAGE: print_debug
print_debug() {
	printf '\033[1;32mDEBUG:\033[0m ' >> /dev/stderr
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

	local option_debug
	option_debug=$(option_value 'debug')
	if [ "$option_debug" -lt "$debug_level" ]; then
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

	local option_debug
	option_debug=$(option_value 'debug')
	if [ "$option_debug" -lt "$debug_level" ]; then
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
	local option_debug
	option_debug=$(option_value 'debug')
	if [ "$option_debug" -eq 0 ]; then
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
	local option_debug
	option_debug=$(option_value 'debug')
	if [ "$option_debug" -eq 0 ]; then
		return 0
	fi

	local dir_path
	dir_path="$1"
	assert_not_empty 'dir_path' 'debug_using_directory'

	print_debug
	printf 'Using existing directory %s\n' "$dir_path" >> /dev/stderr
	return 0
}

# print the type of the launcher being created
# USAGE: debug_write_launcher $launcher_type
debug_write_launcher() {
	local option_debug
	option_debug=$(option_value 'debug')
	if [ "$option_debug" -eq 0 ]; then
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
	local option_debug
	option_debug=$(option_value 'debug')
	if [ "$option_debug" -eq 0 ]; then
		return 0
	fi

	local external_command
	external_command="$1"
	assert_not_empty 'external_command' 'debug_external_command'

	print_debug
	printf 'Running: %s\n' "$external_command" >> /dev/stderr
	return 0
}
