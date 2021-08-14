# print DEBUG
# USAGE: print_debug
print_debug() {
	printf '\033[1;32mDEBUG:\033[0m ' >> /dev/stderr
	return 0
}

# print an option’s value
# USAGE: debug_option_value $option_name
debug_option_value() {
	local option_name
	local option_value

	if [ "$DEBUG" -eq 0 ]; then
		return 0
	else
		option_name="$1"

		if [ -z "$option_name" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_option_value' '$option_name'
			return 1

		else
			option_value=$(get_value "$option_name")

			print_debug
			printf '%s: %s\n' "$option_name" "$option_value" >> /dev/stderr
			return 0
		fi
	fi
}

# print the name of the entered function
# USAGE: debug_entering_function $function_name [$debug_level]
debug_entering_function() {
	local debug_level
	local function_name

	if [ "$#" -eq 2 ]; then
		debug_level="$2"

		case "$debug_level" in
			([0-9]) ;;
			(*) error_invalid_argument 'debug_level' 'debug_entering_function' ;;
		esac

	else
		debug_level=1
	fi

	if [ "$DEBUG" -lt "$debug_level" ]; then
		return 0
	else
		function_name="$1"

		if [ -z "$function_name" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_entering_function' '$function_name'
			return 1

		else
			print_debug
			printf 'Entering %s\n' "$function_name" >> /dev/stderr
			return 0
		fi
	fi
}

# print the name of the leaved function
# USAGE: debug_leaving_function $function_name [$debug_level]
debug_leaving_function() {
	local debug_level
	local function_name

	if [ "$#" -eq 2 ]; then
		debug_level="$2"

		case "$debug_level" in
			([0-9]) ;;
			(*) error_invalid_argument 'debug_level' 'debug_entering_function' ;;
		esac

	else
		debug_level=1
	fi

	if [ "$DEBUG" -lt "$debug_level" ]; then
		return 0
	else
		function_name="$1"

		if [ -z "$function_name" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_leaving_function' '$function_name'
			return 1

		else
			print_debug
			printf 'Leaving %s\n' "$function_name" >> /dev/stderr
			return 0
		fi
	fi
}

# print the name of the created directory
# USAGE: debug_creating_directory $dir_path
debug_creating_directory() {
	local dir_path

	if [ "$DEBUG" -eq 0 ]; then
		return 0
	else
		dir_path="$1"

		if [ -z "$dir_path" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_creating_directory' '$dir_path'
			return 1

		else
			print_debug
			printf 'Creating directory %s\n' "$dir_path" >> /dev/stderr
			return 0
		fi
	fi
}

# print the name of an used directory
# USAGE: debug_using_directory $dir_path
debug_using_directory() {
	if [ "$DEBUG" -eq 0 ]; then
		return 0
	fi

	# shecllcheck disable=SC2039
	local dir_path
	dir_path="$1"

	if [ -z "$dir_path" ]; then
		error_empty_string 'debug_using_directory' 'dir_path'
		return 1
	fi

	print_debug
	printf 'Using existing directory %s\n' "$dir_path" >> /dev/stderr
	return 0
}

# print the name of a source file found
# USAGE: debug_source_file $filename $source_path $inner_path
debug_source_file() {
	local found_status
	local filename

	###
	# TODO
	# check number of arguments
	###

	if [ "$DEBUG" -lt 2 ]; then
		return 0
	else
		found_status="$1"
		filename="$2"

		if [ -z "$filename" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_source_file' '$filename'
			return 1
		elif [ -z "$found_status" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_source_file' '$found_status'
			return 1

		else
			print_debug
			printf '%s file: %s\n' "$found_status" "${filename}" >> /dev/stderr
			return 0
		fi
	fi
}

# print the id of the package a source file is moved to
# intended to be used after debug_source_file
# USAGE: debug_file_to_package $package_id
debug_file_to_package() {
	local package_id

	if [ "$DEBUG" -lt 3 ]; then
		return 0
	else
		package_id="$1"

		if [ -z "$package_id" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_file_to_package' '$package_id'
			return 1

		else
			print_debug
			printf 'Moving file to: %s\n' "$package_id" >> /dev/stderr
			return 0
		fi
	fi
}

# print the type of the launcher being created
# USAGE: debug_write_launcher $launcher_type
debug_write_launcher() {
	local launcher_type
	local binary_file

	if [ "$DEBUG" -eq 0 ]; then
		return 0
	else
		launcher_type="$1"
		binary_file="$2"

		if [ -z "$launcher_type" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_write_launcher' '$launcher_type'
			return 1
		else
			print_debug
			if [ -z "$binary_file" ]; then
				printf 'Writing launcher: %s\n' "$launcher_type" >> /dev/stderr
			else
				printf 'Writing %s launcher: %s\n' "$launcher_type" "$binary_file" >> /dev/stderr
			fi
			return 0
		fi
	fi
}

# print an external command
# USAGE: debug_external_command $command
debug_external_command() {
	local external_command

	if [ "$DEBUG" -eq 0 ]; then
		return 0
	else
		external_command="$1"

		if [ -z "$external_command" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_external_command' '$external_command'
			return 1
		else
			print_debug
			printf 'Running: %s\n' "$external_command" >> /dev/stderr
			return 0
		fi
	fi
}

# print the path of a non-existant temporary directory
# USAGE: debug_temp_dir_nonexistant $directory
debug_temp_dir_nonexistant() {
	if [ "$DEBUG" -le 1 ]; then
		return 0
	fi

	# shellcheck disable=SC2039
	local directory
	directory="$1"

	if [ -z "$directory" ]; then
		error_empty_string 'debug_temp_dir_nonexistant' 'directory'
		return 1
	fi

	print_debug
	printf 'Skipping non-existant directory: %s\n' "$directory" >> /dev/stderr
	return 0
}

# print the path of a non-writable temporary directory
# USAGE: debug_temp_dir_nonwritable $directory
debug_temp_dir_nonwritable() {
	if [ "$DEBUG" -le 1 ]; then
		return 0
	fi

	# shellcheck disable=SC2039
	local directory
	directory="$1"

	if [ -z "$directory" ]; then
		error_empty_string 'debug_temp_dir_nonwritable' 'directory'
		return 1
	fi

	print_debug
	printf 'Skipping non-writable directory: %s\n' "$directory" >> /dev/stderr
	return 0
}

# print the path of a too small temporary directory
# USAGE: debug_temp_dir_not_enough_space $directory
debug_temp_dir_not_enough_space() {
	if [ "$DEBUG" -le 1 ]; then
		return 0
	fi

	# shellcheck disable=SC2039
	local directory
	directory="$1"

	if [ -z "$directory" ]; then
		error_empty_string 'debug_temp_dir_not_enough_space' 'directory'
		return 1
	fi

	print_debug
	printf 'Skipping too small directory: %s\n' "$directory" >> /dev/stderr
	return 0
}
