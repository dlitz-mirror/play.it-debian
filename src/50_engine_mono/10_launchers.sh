# Mono launcher - Print the script content
# USAGE: mono_launcher $application
mono_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			launcher_headers
			mono_launcher_environment "$application"

			# Generate the game prefix
			launcher_prefix_symlinks_functions
			launcher_prefix_symlinks_build

			# Set up the paths diversion to persistent storage
			persistent_storage_initialization
			persistent_storage_common
			persistent_path_diversion
			persistent_storage_update_directories
			persistent_storage_update_files

			mono_launcher_run "$application"

			# Update persistent storage with files from the current prefix
			persistent_storage_update_files_from_prefix

			launcher_exit
		;;
		('none')
			launcher_headers
			mono_launcher_environment "$application"
			mono_launcher_run "$application"
			launcher_exit
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

# Mono launcher - Set the environment
# USAGE: mono_launcher_environment $application
mono_launcher_environment() {
	local application
	application="$1"

	local game_id path_game application_exe application_options
	game_id=$(game_id)
	path_game=$(path_game_data)
	application_exe=$(application_exe_escaped "$application")
	application_libs=$(application_libs "$application")
	application_options=$(application_options "$application")

	cat <<- EOF
	# Set the environment

	GAME_ID='$game_id'
	PATH_GAME='$path_game'
	APP_EXE='$application_exe'
	APP_LIBS='$application_libs'
	APP_OPTIONS="$application_options"

	EOF
}

# Mono launcher - Run Mono
# USAGE: mono_launcher_run $application
mono_launcher_run() {
	local application
	application="$1"

	local prefix_type execution_path
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			execution_path='$PATH_PREFIX'
		;;
		('none')
			execution_path='$PATH_GAME'
		;;
	esac
	cat <<- EOF
	# Run the game

	cd "$execution_path"

	EOF

	# Set loading paths for libraries
	native_launcher_libraries

	application_prerun "$application"

	# Apply common workarounds for Mono games
	mono_launcher_tweaks

	cat <<- 'EOF'
	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit

	## Silence ShellCheck false-positive
	## Double quote to prevent globbing and word splitting.
	# shellcheck disable=SC2086
	mono "$APP_EXE" $APP_OPTIONS "$@"

	game_exit_status=$?
	set -o errexit

	EOF

	application_postrun "$application"
}

# Mono launcher - Common workarounds
# USAGE: mono_launcher_tweaks
mono_launcher_tweaks() {
	cat <<- 'EOF'
	## Work around terminfo Mono bug,
	## cf. https://github.com/mono/mono/issues/6752
	export TERM="${TERM%-256color}"

	## Work around Mono unpredictable behaviour with non-US locales
	export LANG=C

	EOF
}
