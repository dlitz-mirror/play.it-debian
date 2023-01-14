# Load options values from the configuration file.
# USAGE: load_configuration_file $config_file_path
load_configuration_file() {
	local config_file_path
	config_file_path="$1"

	# Default configuration file may not exist, ignoring this then.
	if [ ! -f "$config_file_path" ]; then
		return 0
	fi

	# Parse the configuration file.
	local arguments
	arguments=''
	while read -r line; do
		case $line in
			('#'*)
				# Ignore commented lines.
			;;
			(*)
				arguments="$arguments $line"
			;;
		esac
	done <<- EOF
		$(cat "$config_file_path")
	EOF

	parse_arguments $arguments
}

# Print the configuration file path.
# USAGE: find_configuration_file $arguments[…]
find_configuration_file() {
	local config_file_path
	config_file_path=''

	# Override the default path if another one has been specified.
	while [ $# -gt 0 ]; do
		case "$1" in
			('--config-file='*|\
			 '--config-file'|\
			 '-c')
				if [ "${1%=*}" != "${1#*=}" ]; then
					config_file_path="${1#*=}"
				else
					config_file_path="$2"
				fi
				break
				;;
		esac
		shift 1
	done

	if \
		[ -n "$config_file_path" ] \
		&& [ ! -f "$config_file_path" ]
	then
		error_config_file_not_found "$config_file_path"
		return 1
	fi

	# Fall back on the default path is not custom one is set.
	if [ -z "$config_file_path" ]; then
		config_file_path=$(configuration_file_default_path)
	fi

	printf '%s' "$config_file_path"
	return 0
}

# parse arguments given to the script
# USAGE: parse_arguments $arguments[…]
parse_arguments() {
	local option
	local value

	while [ $# -gt 0 ]; do
		case "$1" in
			('--help')
				help
				exit 0
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
				if [ "${1%=*}" != "${1#*=}" ]; then
					option="$(printf '%s' "${1%=*}" | sed 's/^--//;s/-/_/g')"
					value="${1#*=}"
				else
					option="$(printf '%s' "$1" | sed 's/^--//;s/-/_/g')"
					value="$2"
					shift 1
				fi
				if [ "$value" = 'help' ]; then
					eval help_$option
					exit 0
				else
					# shellcheck disable=SC2046
					eval OPTION_$(printf '%s' "$option" | sed 's/-/_/g' | tr '[:lower:]' '[:upper:]')=\"$value\"
					# shellcheck disable=SC2046
					export OPTION_$(printf '%s' "$option" | sed 's/-/_/g' | tr '[:lower:]' '[:upper:]')
				fi
				unset option
				unset value
			;;
			('--skip-free-space-check')
				NO_FREE_SPACE_CHECK='1'
				export NO_FREE_SPACE_CHECK
			;;
			('--overwrite')
				OVERWRITE_PACKAGES=1
				export OVERWRITE_PACKAGES
			;;
			('--debug'|'--debug='*)
				if [ "${1%=*}" != "${1#*=}" ]; then
					DEBUG="${1#*=}"
				else
					case "$2" in
						([0-9])
							DEBUG="$2"
							shift 1
							;;
						(*)
							DEBUG=1
					esac
				fi
				export DEBUG
			;;
			('--no-mtree')
				MTREE=0
				export MTREE
			;;
			('--config-file='*|\
			 '--config-file'|\
			 '-c')
				if [ "${1%=*}" = "${1#*=}" ]; then
					shift 1
				fi
			;;
			('--list-packages')
				PRINT_LIST_OF_PACKAGES=1
				export PRINT_LIST_OF_PACKAGES
			;;
			('--list-requirements')
				PRINT_REQUIREMENTS=1
				export PRINT_REQUIREMENTS
			;;
			('--'*)
				error_option_unknown "$1"
				return 1
			;;
			(*)
				if [ -f "$1" ]; then
					SOURCE_ARCHIVE="$1"
					export SOURCE_ARCHIVE
				else
					error_not_a_file "$1"
					return 1
				fi
			;;
		esac
		shift 1
	done

	return 0
}

# Print the default path to the configuration file
# USAGE: configuration_file_default_path
# RETURN: a string representing a path to a file,
#         no check of the file actual existence is done
configuration_file_default_path() {
	local configuration_path
	if variable_is_empty 'XDG_CONFIG_HOME'; then
		configuration_path="${HOME}/.config"
	else
		configuration_path="$XDG_CONFIG_HOME"
	fi
	printf '%s/play.it/config' "$configuration_path"
}
