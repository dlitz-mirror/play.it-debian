# Parse the arguments given to the game script or wrapper
# USAGE: parse_arguments $arguments[…]
parse_arguments() {
	local option_name option_value
	while [ $# -gt 0 ]; do
		unset option_name option_value
		case "$1" in
			('--help')
				help
				exit 0
			;;
			('--no-mtree')
				export MTREE=0
			;;
			('--skip-free-space-check')
				export NO_FREE_SPACE_CHECK=1
			;;
			('--overwrite')
				export OVERWRITE_PACKAGES=1
			;;
			('--list-packages')
				export PRINT_LIST_OF_PACKAGES=1
			;;
			('--list-requirements')
				export PRINT_REQUIREMENTS=1
			;;
			( \
				'--config-file='* | \
				'--config-file' | \
				'-c' \
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
					option_value=$(argument_value "$1")
				else
					option_value=$(argument_value "$1" "$2")
					shift 1
				fi
				case "$option_value" in
					([0-9])
						export DEBUG="$option_value"
					;;
					(*)
						export DEBUG=1
					;;
				esac
			;;
			( \
				'--checksum='*| \
				'--checksum'| \
				'--compression='*| \
				'--compression'| \
				'--prefix='*| \
				'--prefix'| \
				'--package='*| \
				'--package'| \
				'--icons='*| \
				'--icons'| \
				'--output-dir='*| \
				'--output-dir'| \
				'--tmpdir='*| \
				'--tmpdir'* \
			)
				if printf '%s' "$1" | grep --quiet --fixed-strings --regexp='='; then
					option_name=$(argument_name "$1")
					option_value=$(argument_value "$1")
				else
					option_name=$(argument_name "$1" "$2")
					option_value=$(argument_value "$1" "$2")
					shift 1
				fi
				if [ "$option_value" = 'help' ]; then
					eval help_$option_name
					exit 0
				else
					local option_variable
					option_variable="OPTION_$(
						printf '%s' "$option_name" | \
							sed 's/-/_/g' | \
							tr '[:lower:]' '[:upper:]' \
					)"
					export $option_variable="$option_value"
				fi
			;;
			('--'*)
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
