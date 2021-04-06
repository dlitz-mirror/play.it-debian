# print DEBUG
# USAGE: print_debug
print_debug() {
	printf '\033[1;32mDEBUG:\033[0m '
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
			printf '%s: %s\n' "$option_name" "$option_value"
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

	if [ "$DEBUG" -ge "$debug_level" ]; then
		return 0
	else
		function_name="$1"

		if [ -z "$function_name" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_entering_function' '$function_name'
			return 1

		else
			print_debug
			printf 'Entering %s\n' "$function_name"
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

	if [ "$DEBUG" -ge "$debug_level" ]; then
		return 0
	else
		function_name="$1"

		if [ -z "$function_name" ]; then
			# shellcheck disable=SC2016
			error_empty_string 'debug_leaving_function' '$function_name'
			return 1

		else
			print_debug
			printf 'Leaving %s\n' "$function_name"
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
			printf 'Creating directory %s\n' "$dir_path"
			return 0
		fi
	fi
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
			printf '%s file: %s\n' "$found_status" "${filename}"
			return 0
		fi
	fi
}

