if [ "$(basename "$0")" != 'libplayit2.sh' ] && [ -z "$LIB_ONLY" ]; then

	# Exit immediately on error
	set -o errexit

	# Set input field separator to default value (space, tab, newline)
	unset IFS

	# Unset variables that we do not want to import from the user environment

	unset SOURCE_ARCHIVE
	unset PLAYIT_WORKDIR

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

	# Set options

	## Set hardcoded defaults
	options_init_default

	## Load defaults from the configuration file
	config_file_path=$(find_configuration_file "$@")
	load_configuration_file "$config_file_path"

	## Set options from the command-line
	parse_arguments "$@"

	# Display the help message,
	# if called with --help.

	if option_is_set 'help'; then
		option_help=$(option_value 'help')
		if [ "$option_help" -eq 1 ]; then
			help
			exit 0
		fi
	fi
	unset option_help

	# Display the version string,
	# if called with --version.

	if option_is_set 'version'; then
		option_version=$(option_value 'version')
		if [ "$option_version" -eq 1 ]; then
			printf '%s\n' "$LIBRARY_VERSION"
			exit 0
		fi
	fi
	unset option_version

	# Try to detect the host distribution if no package format has been explicitely set

	if ! option_is_set 'package'; then
		option_package=$(package_format_guess)
		if [ -z "$option_package" ]; then
			option_package=$(option_value_default 'package')
			warning_package_format_guessing_failed "$option_package"
		fi
		option_update 'package' "$option_package"
	fi
	unset option_package

	# Set options not already set by script arguments to default values

	for option_name in \
		'checksum' \
		'compression' \
		'debug' \
		'free-space-check' \
		'icons' \
		'list-packages' \
		'list-requirements' \
		'mtree' \
		'output-dir' \
		'overwrite' \
		'prefix' \
		'show-game-script' \
		'tmpdir'
	do
		if ! option_is_set "$option_name"; then
			option_value=$(option_value_default "$option_name")
			option_update "$option_name" "$option_value"
		fi
	done
	unset option_value

	# Throw an error if incompatible options are set

	options_compatibility_check

	# Find the main archive

	archives_list=$(archives_return_list)
	ARCHIVE=$(archive_find_from_candidates 'SOURCE_ARCHIVE' $archives_list)
	if [ -z "$ARCHIVE" ]; then
		error_archive_not_found $archives_list
		exit 0
	fi
	export ARCHIVE
	unset archives_list

	# Display the path to the game script,
	# if called with --show-game-script.

	if option_is_set 'show-game-script'; then
		option_show_game_script=$(option_value 'show-game-script')
		if [ "$option_show_game_script" -eq 1 ]; then
			printf '%s\n' "$(realpath "$0")"
			exit 0
		fi
	fi
	unset option_show_game_script

	# If called with --list-packages,
	# print the list of packages that would be generated from the given archive
	# then exit early.

	option_list_packages=$(option_value 'list-packages')
	if [ "$option_list_packages" -eq 1 ]; then
		packages_print_list "$ARCHIVE"
		exit 0
	fi
	unset option_list_packages

	# If called with --list-requirements,
	# print the list of commands required to run the current game script
	# then exit early.

	option_list_requirements=$(option_value 'list-requirements')
	if [ "$option_list_requirements" -eq 1 ]; then
		requirements_list
		exit 0
	fi
	unset option_list_requirements

	# Check the presence of required tools

	check_deps
	archive_dependencies_check "$ARCHIVE"

	# Set the main archive properties,
	# and check its integrity.

	archives_list=$(archives_return_list)
	archive_initialize_required 'SOURCE_ARCHIVE' $archives_list
	unset archives_list

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
