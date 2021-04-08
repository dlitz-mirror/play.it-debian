if [ "$(basename "$0")" != 'libplayit2.sh' ] && [ -z "$LIB_ONLY" ]; then

	# Exit immediately on error
	set -o errexit

	# Set input field separator to default value (space, tab, newline)
	unset IFS

	# Unset variables that we do not want to import from the user environment

	unset OPTION_ARCHITECTURE
	unset OPTION_CHECKSUM
	unset OPTION_COMPRESSION
	unset OPTION_PREFIX
	unset OPTION_PACKAGE
	unset SOURCE_ARCHIVE
	unset PLAYIT_WORKDIR
	unset winecfg_desktop
	unset winecfg_launcher

	# Set URLs for error messages

	PLAYIT_GAMES_BUG_TRACKER_URL='https://forge.dotslashplay.it/play.it/games/issues'
	PLAYIT_BUG_TRACKER_URL='https://forge.dotslashplay.it/play.it/scripts/issues'

	# Check library version against script target version

	if [ -z "${target_version:=}" ]; then
		error_missing_target_version
	fi
	VERSION_MAJOR_PROVIDED="${LIBRARY_VERSION%%.*}"
	VERSION_MAJOR_TARGET="${target_version%%.*}"
	VERSION_MINOR_PROVIDED=$(printf '%s' "$LIBRARY_VERSION" | cut --delimiter='.' --fields=2)
	VERSION_MINOR_TARGET=$(printf '%s' "$target_version" | cut --delimiter='.' --fields=2)
	if \
		[ $VERSION_MAJOR_PROVIDED -ne $VERSION_MAJOR_TARGET ] || \
		[ $VERSION_MINOR_PROVIDED -lt $VERSION_MINOR_TARGET ]
	then
		error_incompatible_versions
	fi
	export VERSION_MAJOR_PROVIDED VERSION_MAJOR_TARGET VERSION_MINOR_PROVIDED VERSION_MINOR_TARGET

	# Set allowed values for common options

	# shellcheck disable=SC2034
	ALLOWED_VALUES_ARCHITECTURE='all 32 64 auto'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_CHECKSUM='none md5'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_COMPRESSION_DEB='none gzip xz'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_COMPRESSION_ARCH='none gzip xz bzip2 zstd'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_COMPRESSION_GENTOO='gzip xz bzip2 zstd lz4 lzip lzop'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_COMPRESSION_EGENTOO='none gzip xz bzip2'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_PACKAGE='arch deb gentoo egentoo'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_ICONS='yes no auto'

	# Set default values for common options

	# shellcheck disable=SC2034
	DEFAULT_OPTION_ARCHITECTURE='all'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_CHECKSUM='md5'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_COMPRESSION_ARCH='zstd'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_COMPRESSION_DEB='none'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_COMPRESSION_GENTOO='bzip2'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_COMPRESSION_EGENTOO='bzip2'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_PREFIX_DEB='/usr/local'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_PREFIX_ARCH='/usr'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_PREFIX_GENTOO='/usr'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_PREFIX_EGENTOO='/usr'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_PACKAGE='deb'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_ICONS='yes'
	# shellcheck disable=SC2034
	DEFAULT_OPTION_OUTPUT_DIR="$PWD"

	# Parse arguments given to the script

	DRY_RUN='0'
	NO_FREE_SPACE_CHECK='0'
	SKIP_ICONS=0
	OVERWRITE_PACKAGES=0
	DEBUG=0

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
			;;
			(*)
				if [ -f "$1" ]; then
					SOURCE_ARCHIVE="$1"
					export SOURCE_ARCHIVE
				else
					error_not_a_file "$1"
				fi
			;;
		esac
		shift 1
	done

	# Try to detect the host distribution if no package format has been explicitely set

	[ "$OPTION_PACKAGE" ] || packages_guess_format 'OPTION_PACKAGE'

	# Check option validity for the package format, since it will be used for the compression method

	check_option_validity 'PACKAGE'

	# Set allowed and default values for compression and prefix depending on the chosen package format

	# shellcheck disable=SC2034
	ALLOWED_VALUES_COMPRESSION="$(get_value "ALLOWED_VALUES_COMPRESSION_$(printf '%s' "$OPTION_PACKAGE" | tr '[:lower:]' '[:upper:]')")"
	# shellcheck disable=SC2034
	DEFAULT_OPTION_COMPRESSION="$(get_value "DEFAULT_OPTION_COMPRESSION_$(printf '%s' "$OPTION_PACKAGE" | tr '[:lower:]' '[:upper:]')")"
	# shellcheck disable=SC2034
	DEFAULT_OPTION_PREFIX="$(get_value "DEFAULT_OPTION_PREFIX_$(printf '%s' "$OPTION_PACKAGE" | tr '[:lower:]' '[:upper:]')")"

	# Set options not already set by script arguments to default values

	for option in 'ARCHITECTURE' 'CHECKSUM' 'COMPRESSION' 'ICONS' 'OUTPUT_DIR' 'PREFIX'; do
		if
			[ -z "$(get_value "OPTION_$option")" ] && \
			[ -n "$(get_value "DEFAULT_OPTION_$option")" ]
		then
			# shellcheck disable=SC2046
			eval OPTION_$option=\"$(get_value "DEFAULT_OPTION_$option")\"
			export OPTION_$option
		fi
	done

	# Check options values validity

	for option in 'CHECKSUM' 'COMPRESSION' 'ICONS'; do
		check_option_validity "$option"
	done

	if [ "$OPTION_ICONS" = 'no' ]; then
		SKIP_ICONS=1
		export SKIP_ICONS
	fi

	case "$DEBUG" in
		([0-9]) ;;
		(*)
			error_option_invalid 'DEBUG' "$DEBUG"
		;;
	esac

	# DEBUG: output all options value
	for option in 'DRY_RUN' 'NO_FREE_SPACE_CHECK' \
		'SKIP_ICONS' 'OVERWRITE_PACKAGES' 'DEBUG'; do
		debug_option_value "$option"
	done
	for option in 'ARCHITECTURE' 'CHECKSUM' 'COMPRESSION' \
		'PREFIX' 'PACKAGE' 'OUTPUT_DIR'; do
		debug_option_value "OPTION_$option"
	done

	# Make sure the output directory exists and is writable

	OPTION_OUTPUT_DIR=$(printf '%s' "$OPTION_OUTPUT_DIR" | sed "s#^~#$HOME#")
	if [ ! -d "$OPTION_OUTPUT_DIR" ]; then
		error_not_a_directory "$OPTION_OUTPUT_DIR"
	fi
	if [ ! -w "$OPTION_OUTPUT_DIR" ]; then
		error_not_writable "$OPTION_OUTPUT_DIR"
	fi
	export OPTION_OUTPUT_DIR

	# Restrict packages list to target architecture

	select_package_architecture

	# Check script dependencies

	check_deps

	# Set package paths

	case $OPTION_PACKAGE in
		('arch'|'gentoo'|'egentoo')
			PATH_BIN="$OPTION_PREFIX/bin"
			PATH_DESK="$DEFAULT_OPTION_PREFIX/share/applications"
			PATH_DOC="$OPTION_PREFIX/share/doc/$GAME_ID"
			PATH_GAME="$OPTION_PREFIX/share/$GAME_ID"
			PATH_ICON_BASE="$DEFAULT_OPTION_PREFIX/share/icons/hicolor"
		;;
		('deb')
			PATH_BIN="$OPTION_PREFIX/games"
			PATH_DESK="$DEFAULT_OPTION_PREFIX/share/applications"
			PATH_DOC="$OPTION_PREFIX/share/doc/$GAME_ID"
			PATH_GAME="$OPTION_PREFIX/share/games/$GAME_ID"
			PATH_ICON_BASE="$DEFAULT_OPTION_PREFIX/share/icons/hicolor"
		;;
		(*)
			error_invalid_argument 'OPTION_PACKAGE' "$0"
		;;
	esac

	# Set main archive

	# shellcheck disable=SC2046
	archive_initialize_required 'SOURCE_ARCHIVE' $(archives_return_list)
	# shellcheck disable=SC2046
	ARCHIVE=$(archive_find_from_candidates 'SOURCE_ARCHIVE' $(archives_return_list))
	export ARCHIVE

	# Set working directories

	# shellcheck disable=SC2046
	set_temp_directories $(packages_get_list)

fi
