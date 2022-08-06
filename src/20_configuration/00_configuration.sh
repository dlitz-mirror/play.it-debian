# load configuration file options values
# USAGE: load_configuration_file $config_file_path
load_configuration_file() {
	local config_file_path
	local arguments

	config_file_path="$1"

	# Default config file may not exist, ignoring this then
	if [ ! -f "$config_file_path" ]; then
		return 0
	fi

	while read -r line; do
		case $line in
			('#'*) ;;
			(*) arguments="$arguments $line" ;;
		esac
	done <<- EOF
		$(cat "$config_file_path")
	EOF

	parse_arguments $arguments
}

# print configuration file path
# USAGE: find_configuration_file $arguments[…]
find_configuration_file() {
	local config_file_path

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

	if [ -n "$config_file_path" ]; then
		if [ ! -f "$config_file_path" ]; then
			error_config_file_not_found "$config_file_path"
			return 1
		fi
	else
		config_file_path="${XDG_CONFIG_HOME:="$HOME/.config"}/play.it/config"
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
