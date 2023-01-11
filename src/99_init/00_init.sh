if [ "$(basename "$0")" != 'libplayit2.sh' ] && [ -z "$LIB_ONLY" ]; then

	# Exit immediately on error
	set -o errexit

	# Set input field separator to default value (space, tab, newline)
	unset IFS

	# Unset variables that we do not want to import from the user environment

	unset OPTION_CHECKSUM
	unset OPTION_COMPRESSION
	unset OPTION_PREFIX
	unset OPTION_PACKAGE
	unset SOURCE_ARCHIVE
	unset PLAYIT_WORKDIR
	unset winecfg_desktop
	unset winecfg_launcher

	# Set default values

	PRINT_LIST_OF_PACKAGES=0
	PRINT_REQUIREMENTS=0

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
	ALLOWED_VALUES_ICONS='yes no'

	# Set default values for common options

	export DEFAULT_OPTION_CHECKSUM='md5'
	export DEFAULT_OPTION_COMPRESSION_ARCH='zstd'
	export DEFAULT_OPTION_COMPRESSION_DEB='none'
	export DEFAULT_OPTION_COMPRESSION_GENTOO='bzip2'
	export DEFAULT_OPTION_COMPRESSION_EGENTOO='bzip2'
	export DEFAULT_OPTION_PREFIX='/usr'
	export DEFAULT_OPTION_PACKAGE='deb'
	export DEFAULT_OPTION_ICONS='yes'
	export DEFAULT_OPTION_OUTPUT_DIR="$PWD"
	export DEFAULT_NO_FREE_SPACE_CHECK=0
	export DEFAULT_OVERWRITE_PACKAGES=0
	export DEFAULT_DEBUG=0
	export DEFAULT_MTREE=1

	# Load configuration file values

	config_file_path=$(find_configuration_file "$@")
	load_configuration_file "$config_file_path"

	# Parse arguments given to the script

	parse_arguments "$@"

	# Try to detect the host distribution if no package format has been explicitely set

	if variable_is_empty 'OPTION_PACKAGE'; then
		OPTION_PACKAGE=$(package_format_guess)
	fi
	if variable_is_empty 'OPTION_PACKAGE'; then
		warning_package_format_guessing_failed "$DEFAULT_OPTION_PACKAGE"
		OPTION_PACKAGE="$DEFAULT_OPTION_PACKAGE"
	fi

	# Check option validity for the package format, since it will be used for the compression method

	check_option_validity 'PACKAGE'

	# Set allowed and default values for compression and prefix depending on the chosen package format

	# shellcheck disable=SC2034
	ALLOWED_VALUES_COMPRESSION="$(get_value "ALLOWED_VALUES_COMPRESSION_$(printf '%s' "$OPTION_PACKAGE" | tr '[:lower:]' '[:upper:]')")"
	# shellcheck disable=SC2034
	DEFAULT_OPTION_COMPRESSION="$(get_value "DEFAULT_OPTION_COMPRESSION_$(printf '%s' "$OPTION_PACKAGE" | tr '[:lower:]' '[:upper:]')")"

	# Set options not already set by script arguments to default values

	for option in \
		'OPTION_CHECKSUM' \
		'OPTION_COMPRESSION' \
		'OPTION_ICONS' \
		'OPTION_OUTPUT_DIR' \
		'OPTION_PREFIX' \
		'NO_FREE_SPACE_CHECK' \
		'OVERWRITE_PACKAGES' \
		'DEBUG' \
		'MTREE'
	do
		if \
			variable_is_empty "$option" \
			&& ! variable_is_empty "DEFAULT_$option"
		then
			option_default_value=$(get_value "DEFAULT_$option")
			export $option="$option_default_value"
		fi
	done

	# Check options values validity

	for option in 'CHECKSUM' 'COMPRESSION' 'ICONS'; do
		check_option_validity "$option"
	done

	case "$DEBUG" in
		([0-9]) ;;
		(*)
			error_option_invalid 'DEBUG' "$DEBUG"
			exit 1
		;;
	esac

	# DEBUG: output all options value
	for option in \
		'NO_FREE_SPACE_CHECK' \
		'OVERWRITE_PACKAGES' \
		'DEBUG' \
		'MTREE'
	do
		debug_option_value "$option"
		true
	done
	for option in 'CHECKSUM' 'COMPRESSION' \
		'PREFIX' 'PACKAGE' 'OUTPUT_DIR'; do
		debug_option_value "OPTION_$option"
		true
	done

	# Find the main archive

	archives_list=$(archives_return_list)
	ARCHIVE=$(archive_find_from_candidates 'SOURCE_ARCHIVE' $archives_list)
	export ARCHIVE

	# If called with --list-packages,
	# print the list of packages that would be generated from the given archive
	# then exit early.

	if [ $PRINT_LIST_OF_PACKAGES -eq 1 ]; then
		packages_print_list "$ARCHIVE"
		exit 0
	fi

	# If called with --list-requirements,
	# print the list of commands required to run the current game script
	# then exit early.

	if [ $PRINT_REQUIREMENTS -eq 1 ]; then
		requirements_list
		exit 0
	fi

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

	# Check the presence of required tools

	check_deps
	archive_dependencies_check "$ARCHIVE"

	# Set the main archive properties,
	# and check its integrity.

	archive_initialize_required 'SOURCE_ARCHIVE' $archives_list

	# Set path to working directory

	set_temp_directories

	# Legacy - Export install paths as global variables.
	# Pre-2.19 game scripts might rely on the availability of these global variables.
	# New game scripts should not rely on these, as they are deprecated and will be dropped in some future release.
	PATH_BIN=$(path_binaries)
	PATH_DESK=$(path_xdg_desktop)
	PATH_DOC=$(path_documentation)
	PATH_GAME=$(path_game_data)
	PATH_ICON_BASE=$(path_icons)
	export PATH_BIN PATH_DESK PATH_DOC PATH_GAME PATH_ICON_BASE
fi
