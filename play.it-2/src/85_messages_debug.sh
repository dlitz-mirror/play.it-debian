# print DEBUG
# USAGE: print_debug
print_debug() {
	printf '\033[1;32mDEBUG:\033[0m '
	return 0
}

# print an option’s value
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

