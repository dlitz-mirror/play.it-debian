# Parse the arguments given to the game script or wrapper
# WARNING: Options that are already set from the user environment are not overriden.
# USAGE: parse_arguments $arguments[…]
parse_arguments() {
	local option_name option_variable option_value
	while [ $# -gt 0 ]; do
		unset option_name option_variable option_value
		case "$1" in
			( \
				'--help' | \
				'--list-packages' | \
				'--list-requirements' | \
				'--overwrite' | \
				'--show-game-script' | \
				'--version' \
			)
				option_name=$(argument_name "$1")
				option_update "$option_name" 1
			;;
			( \
				'--no-free-space-check' | \
				'--no-icons' | \
				'--no-mtree' \
			)
				option_name=$(argument_name "$1" | sed 's/^no-//')
				option_update "$option_name" 0
			;;
			( \
				'--config-file' | \
				'--config-file='* \
			)
				# Skip this argument, has it should have already been handled by find_configuration_file.
				if ! printf '%s' "$1" | grep --quiet --fixed-strings --regexp='='; then
					shift 1
				fi
			;;
			( \
				'--debug' | \
				'--debug='* \
			)
				if printf '%s' "$1" | grep --quiet --fixed-strings --regexp='='; then
					option_name=$(argument_name "$1")
					option_variable=$(option_variable "$option_name")
					option_value=$(argument_value "$1")
				else
					option_name=$(argument_name "$1" "$2")
					option_variable=$(option_variable "$option_name")
					option_value=$(argument_value "$1" "$2")
					shift 1
				fi
				case "$option_value" in
					([0-9])
						option_update "$option_name" "$option_value"
					;;
					(*)
						option_update "$option_name" 1
					;;
				esac
			;;
			( \
				'--checksum' | \
				'--checksum='* | \
				'--compression' | \
				'--compression='* | \
				'--output-dir' | \
				'--output-dir='* | \
				'--package' | \
				'--package='* | \
				'--prefix' | \
				'--prefix='* | \
				'--tmpdir' | \
				'--tmpdir='* \
			)
				if printf '%s' "$1" | grep --quiet --fixed-strings --regexp='='; then
					option_name=$(argument_name "$1")
					option_variable=$(option_variable "$option_name")
					option_value=$(argument_value "$1")
				else
					option_name=$(argument_name "$1" "$2")
					option_variable=$(option_variable "$option_name")
					option_value=$(argument_value "$1" "$2")
					shift 1
				fi
				option_update "$option_name" "$option_value"
			;;
			('-'*)
				error_option_unknown "$1"
				return 1
			;;
			(*)
				if [ -f "$1" ]; then
					export SOURCE_ARCHIVE="$1"
				else
					error_not_a_file "$1"
					return 1
				fi
			;;
		esac
		shift 1
	done
}

# Parse the arguments set through the configuration file
# WARNING: Only a subset of the supported options are allowed here.
# USAGE: parse_arguments $arguments[…]
parse_arguments_default() {
	local option_name option_value
	while [ $# -gt 0 ]; do
		unset option_name option_value
		case "$1" in
			( \
				'--overwrite' \
			)
				option_name=$(argument_name "$1")
				option_update_default "$option_name" 1
			;;
			( \
				'--no-free-space-check' | \
				'--no-icons' | \
				'--no-mtree' \
			)
				option_name=$(argument_name "$1" | sed 's/^no-//')
				option_update_default "$option_name" 0
			;;
			( \
				'--debug' | \
				'--debug='* \
			)
				if printf '%s' "$1" | grep --quiet --fixed-strings --regexp='='; then
					option_name=$(argument_name "$1")
					option_value=$(argument_value "$1")
				else
					option_name=$(argument_name "$1" "$2")
					option_value=$(argument_value "$1" "$2")
					shift 1
				fi
				case "$option_value" in
					([0-9])
						option_update_default "$option_name" "$option_value"
					;;
					(*)
						option_update_default "$option_name" 1
					;;
				esac
			;;
			( \
				'--checksum' | \
				'--checksum='* | \
				'--compression' | \
				'--compression='* | \
				'--output-dir' | \
				'--output-dir='* | \
				'--package' | \
				'--package='* | \
				'--prefix' | \
				'--prefix='* | \
				'--tmpdir' | \
				'--tmpdir='* \
			)
				if printf '%s' "$1" | grep --quiet --fixed-strings --regexp='='; then
					option_name=$(argument_name "$1")
					option_value=$(argument_value "$1")
				else
					option_name=$(argument_name "$1" "$2")
					option_value=$(argument_value "$1" "$2")
					shift 1
				fi
				option_update_default "$option_name" "$option_value"
			;;
			('--'*)
				error_option_unknown "$1"
				return 1
			;;
		esac
		shift 1
	done
}

# Print the name of the option set using the given argument string
# USAGE: argument_name $argument_string
# RETURN: the option name
argument_name() {
	local argument_string
	argument_string="$*"

	# Keep only the option name,
	# without the value it is set to,
	# and without the "--" prefix.
	local cut_delimiter
	if printf '%s' "$argument_string" | grep --quiet --fixed-strings --regexp='='; then
		cut_delimiter='='
	else
		cut_delimiter=' '
	fi
	printf '%s' "$argument_string" | \
		cut --delimiter="$cut_delimiter" --fields=1 | \
		sed 's/^--//'
}

# Print the value of the option set using the given argument string
# USAGE: argument_value $argument_string
# RETURN: the option value
argument_value() {
	local argument_string
	argument_string="$*"

	# Keep only the option value,
	# without the name of the option that is set to it.
	local cut_delimiter
	if printf '%s' "$argument_string" | grep --quiet --fixed-strings --regexp='='; then
		cut_delimiter='='
	else
		cut_delimiter=' '
	fi
	printf '%s' "$argument_string" | \
		cut --delimiter="$cut_delimiter" --fields=2- | \
		sed 's/^--//'
}
