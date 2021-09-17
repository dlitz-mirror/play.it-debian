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
			('--architecture='*|\
			 '--architecture'|\
			 '--checksum='*|\
			 '--checksum'|\
			 '--compression='*|\
			 '--compression'|\
			 '--prefix='*|\
			 '--prefix'|\
			 '--package='*|\
			 '--package'|\
			 '--icons='*|\
			 '--icons'|\
			 '--output-dir='*|\
			 '--output-dir')
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
			('--dry-run')
				DRY_RUN='1'
				export DRY_RUN
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
