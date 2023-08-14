# Clean up the command-line parameters using getopt
# USAGE: getopt_arguments_cleanup $arguments[…]
# RETURN: a standardized parameters string
getopt_arguments_cleanup() {
	getopt \
		--name 'play.it' \
		--shell 'sh' \
		--options '' \
		--longoptions 'help' \
		--longoptions 'list-available-scripts' \
		--longoptions 'list-packages' \
		--longoptions 'list-supported-games' \
		--longoptions 'overwrite' \
		--longoptions 'show-game-script' \
		--longoptions 'version' \
		--longoptions 'no-free-space-check' \
		--longoptions 'no-icons' \
		--longoptions 'no-mtree' \
		--longoptions 'config-file:' \
		--longoptions 'checksum:' \
		--longoptions 'compression:' \
		--longoptions 'output-dir:' \
		--longoptions 'package:' \
		--longoptions 'prefix:' \
		--longoptions 'tmpdir:' \
		--longoptions 'debug::' \
		-- "$@"
}

# Parse the arguments given to the game script or wrapper
# WARNING: Options that are already set from the user environment are not overriden.
# USAGE: parse_arguments $arguments[…]
parse_arguments() {
	local arguments_string
	arguments_string=$(getopt_arguments_cleanup "$@")
	eval set -- "$arguments_string"

	local option_name option_variable option_value
	while [ $# -gt 0 ]; do
		unset option_name option_variable option_value
		case "$1" in
			( \
				'--help' | \
				'--list-available-scripts' | \
				'--list-packages' | \
				'--list-requirements' | \
				'--list-supported-games' | \
				'--overwrite' | \
				'--show-game-script' | \
				'--version' \
			)
				option_name=$(printf '%s' "$1" | sed 's/^--//')
				option_update "$option_name" 1
			;;
			( \
				'--no-free-space-check' | \
				'--no-icons' | \
				'--no-mtree' \
			)
				option_name=$(printf '%s' "$1" | sed 's/^--no-//')
				option_update "$option_name" 0
			;;
			('--config-file')
				# Skip this argument, has it should have already been handled by find_configuration_file.
				shift 1
			;;
			('--debug')
				option_name=$(printf '%s' "$1" | sed 's/^--//')
				option_variable=$(option_variable "$option_name")
				option_value="$2"
				shift 1
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
				'--compression' | \
				'--output-dir' | \
				'--package' | \
				'--prefix' | \
				'--tmpdir' \
			)
				option_name=$(printf '%s' "$1" | sed 's/^--//')
				option_variable=$(option_variable "$option_name")
				option_value="$2"
				shift 1
				option_update "$option_name" "$option_value"
			;;
			('--')
				# Skip the "--" separator.
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
	local arguments_string
	arguments_string=$(getopt_arguments_cleanup "$@")
	eval set -- "$arguments_string"

	local option_name option_value
	while [ $# -gt 0 ]; do
		unset option_name option_value
		case "$1" in
			('--overwrite')
				option_name=$(printf '%s' "$1" | sed 's/^--//')
				option_update_default "$option_name" 1
			;;
			( \
				'--no-free-space-check' | \
				'--no-icons' | \
				'--no-mtree' \
			)
				option_name=$(printf '%s' "$1" | sed 's/^--//')
				option_update_default "$option_name" 0
			;;
			('--debug')
				option_name=$(printf '%s' "$1" | sed 's/^--//')
				option_value="$2"
				shift 1
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
				'--compression' | \
				'--output-dir' | \
				'--package' | \
				'--prefix' | \
				'--tmpdir' \
			)
				option_name=$(printf '%s' "$1" | sed 's/^--//')
				option_value="$2"
				shift 1
				option_update_default "$option_name" "$option_value"
			;;
		esac
		shift 1
	done
}

