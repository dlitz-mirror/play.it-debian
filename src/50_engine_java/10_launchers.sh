# Java launcher - Print the script content
# USAGE: java_launcher $application
java_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			launcher_headers
			java_launcher_environment "$application"

			# Generate the game prefix
			launcher_prefix_symlinks_functions
			launcher_prefix_symlinks_build

			# Set up the paths diversion to persistent storage
			persistent_storage_initialization
			persistent_storage_common
			persistent_path_diversion
			persistent_storage_update_directories
			persistent_storage_update_files

			java_launcher_run "$application"

			# Update persistent storage with files from the current prefix
			persistent_storage_update_files_from_prefix

			launcher_exit
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

# Java launcher - Set the environment
# USAGE: java_launcher_environment $application
java_launcher_environment() {
	local application
	application="$1"

	local game_id path_game application_exe application_options application_java_options
	game_id=$(game_id)
	path_game=$(path_game_data)
	application_exe=$(application_exe_escaped "$application")
	application_options=$(application_options "$application")
	application_java_options=$(application_java_options "$application")
	## Legacy variable APP_xxx_LIBS should not be used with compatibility level ≥ 2.19,
	## a warning will be trigerred is it is set.
	application_libs=$(application_libs_legacy "$application")

	cat <<- EOF
	# Set the environment

	GAME_ID='$game_id'
	PATH_GAME='$path_game'
	APP_EXE='$application_exe'
	APP_OPTIONS="$application_options"
	JAVA_OPTIONS='$application_java_options'
	APP_LIBS='$application_libs'

	EOF
}

# Java launcher - Run Java
# USAGE: java_launcher_run $application
java_launcher_run() {
	local application
	application="$1"

	cat <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF

	# Set loading paths for libraries
	native_launcher_libraries

	application_prerun "$application"

	cat <<- 'EOF'
	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit

	## Silence ShellCheck false-positive
	## Double quote to prevent globbing and word splitting.
	# shellcheck disable=SC2086
	java $JAVA_OPTIONS -jar "$APP_EXE" $APP_OPTIONS "$@"

	game_exit_status=$?
	set -o errexit

	EOF

	application_postrun "$application"
}
