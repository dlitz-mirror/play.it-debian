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
		exit 1
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
		exit 1
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
	ALLOWED_VALUES_COMPRESSION_EGENTOO='none gzip xz bzip2 zstd lzip'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_PACKAGE='arch deb gentoo egentoo'
	# shellcheck disable=SC2034
	ALLOWED_VALUES_ICONS='yes no auto'

	# Set default values for common options

	export DEFAULT_OPTION_ARCHITECTURE='all'
	export DEFAULT_OPTION_CHECKSUM='md5'
	export DEFAULT_OPTION_COMPRESSION_ARCH='zstd'
	export DEFAULT_OPTION_COMPRESSION_DEB='none'
	export DEFAULT_OPTION_COMPRESSION_GENTOO='bzip2'
	export DEFAULT_OPTION_COMPRESSION_EGENTOO='bzip2'
	export DEFAULT_OPTION_PREFIX_DEB='/usr/local'
	export DEFAULT_OPTION_PREFIX_ARCH='/usr'
	export DEFAULT_OPTION_PREFIX_GENTOO='/usr'
	export DEFAULT_OPTION_PREFIX_EGENTOO='/usr'
	export DEFAULT_OPTION_PACKAGE='deb'
	export DEFAULT_OPTION_ICONS='yes'
	export DEFAULT_OPTION_OUTPUT_DIR="$PWD"
	export DEFAULT_DRY_RUN=0
	export DEFAULT_NO_FREE_SPACE_CHECK=0
	export DEFAULT_SKIP_ICONS=0
	export DEFAULT_OVERWRITE_PACKAGES=0
	export DEFAULT_DEBUG=0

	# Load configuration file values

	config_file_path=$(find_configuration_file "$@")
	load_configuration_file "$config_file_path"

	# Parse arguments given to the script

	parse_arguments "$@"

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

	for option in 'DRY_RUN' 'NO_FREE_SPACE_CHECK' 'SKIP_ICONS' 'OVERWRITE_PACKAGES' 'DEBUG'; do
		if
			[ -z "$(get_value "$option")" ] && \
			[ -n "$(get_value "DEFAULT_$option")" ]
		then
			# shellcheck disable=SC2046
			eval $option=\"$(get_value "DEFAULT_$option")\"
			export ${option?}
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
			exit 1
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
		exit 1
	fi
	if [ ! -w "$OPTION_OUTPUT_DIR" ]; then
		error_not_writable "$OPTION_OUTPUT_DIR"
		exit 1
	fi
	export OPTION_OUTPUT_DIR

	# Check script dependencies

	check_deps

	# Set main archive

	# shellcheck disable=SC2046
	archive_initialize_required 'SOURCE_ARCHIVE' $(archives_return_list)
	# shellcheck disable=SC2046
	ARCHIVE=$(archive_find_from_candidates 'SOURCE_ARCHIVE' $(archives_return_list))
	export ARCHIVE

	# Set package paths

	case $OPTION_PACKAGE in
		('arch'|'gentoo'|'egentoo')
			PATH_BIN="$OPTION_PREFIX/bin"
			PATH_DESK="$DEFAULT_OPTION_PREFIX/share/applications"
			PATH_DOC="$OPTION_PREFIX/share/doc/$(game_id)"
			PATH_GAME="$OPTION_PREFIX/share/$(game_id)"
			PATH_ICON_BASE="$DEFAULT_OPTION_PREFIX/share/icons/hicolor"
		;;
		('deb')
			PATH_BIN="$OPTION_PREFIX/games"
			PATH_DESK="$DEFAULT_OPTION_PREFIX/share/applications"
			PATH_DOC="$OPTION_PREFIX/share/doc/$(game_id)"
			PATH_GAME="$OPTION_PREFIX/share/games/$(game_id)"
			PATH_ICON_BASE="$DEFAULT_OPTION_PREFIX/share/icons/hicolor"
		;;
		(*)
			error_invalid_argument 'OPTION_PACKAGE' "$0"
			exit 1
		;;
	esac
	export PATH_BIN PATH_DESK PATH_DOC PATH_GAME PATH_ICON_BASE

	# Restrict packages list to target architecture

	select_package_architecture

	# Set working directories

	# shellcheck disable=SC2046
	set_temp_directories $(packages_get_list)

fi
