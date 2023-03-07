# Linux native - Print application-specific variables
# USAGE: native_launcher_application_variables $application
native_launcher_application_variables() {
	local application
	application="$1"

	local application_exe application_libs application_options
	application_exe=$(application_exe_escaped "$application")
	application_libs=$(application_libs "$application")
	application_options=$(application_options "$application")

	cat <<- EOF
	# Set application-specific values
	APP_EXE='$application_exe'
	APP_LIBS='$application_libs'
	APP_OPTIONS="$application_options"
	EOF
}

# Linux native - Print the actual call to the game binary
# USAGE: native_launcher_run $application
native_launcher_run() {
	local application
	application="$1"

	local application_type_variant
	application_type_variant=$(application_type_variant "$application")

	local execution_path
	execution_path=$(native_launcher_exec_path "$application")
	cat <<- EOF
	# Run the game

	cd "$execution_path"

	EOF

	case "$application_type_variant" in
		('unity3d')
			# Start pulseaudio if it is available
			launcher_unity3d_pulseaudio_start

			# Work around crash on launch related to libpulse
			# Some Unity3D games crash on launch if libpulse-simple.so.0 is available but pulseaudio is not running
			launcher_unity3d_pulseaudio_hide_libpulse

			# Use a dedicated log file for the current game session
			launcher_unity3d_dedicated_log

			# Make a hard copy of the game binary in the current prefix,
			# otherwise the engine might follow the link and run the game from the system path.
			launcher_unity3d_copy_binary

			# Work around Unity3D poor support for non-US locales
			launcher_unity3d_force_locale
		;;
		(*)
			# Make a hard copy of the game binary in the current prefix,
			# otherwise the engine might follow the link and run the game from the system path.
			native_launcher_binary_copy "$application"
		;;
	esac

	# Set loading paths for libraries
	launcher_native_libraries_paths

	application_prerun "$application"

	cat <<- 'EOF'

	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit
	"./$APP_EXE" $APP_OPTIONS "$@"
	game_exit_status=$?
	set -o errexit

	EOF

	application_postrun "$application"

	case "$application_type_variant" in
		('unity3d')
			# Stop pulseaudio if it has been started for this game session
			launcher_unity3d_pulseaudio_stop
		;;
	esac
}

# Linux native - Print the path from where the game binary is called
# USAGE: native_launcher_exec_path $application
native_launcher_exec_path() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			printf '$PATH_PREFIX'
			return 0
		;;
		('none')
			printf '$PATH_GAME'
			return 0
		;;
		(*)
			return 1
		;;
	esac
}

# Linux native - Print the copy command for the game binary
# USAGE: native_launcher_binary_copy $application
native_launcher_binary_copy() {
	local application
	application="$1"

	# Return early if the copy should not be done.
	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			# The copy is required.
		;;
		(*)
			return 0
		;;
	esac

	cat <<- 'EOF'
	## Copy the game binary into the user prefix
	if [ -e "${USER_PERSISTENT_PATH}/${APP_EXE}" ]; then
	    source_dir="$USER_PERSISTENT_PATH"
	else
	    source_dir="$PATH_GAME"
	fi
	(
	    cd "$source_dir"
	    cp --parents --dereference --remove-destination "$APP_EXE" "$PATH_PREFIX"
	)
	EOF
}

# Linux native - Print libraries loading path.
# USAGE: launcher_native_libraries_paths
launcher_native_libraries_paths() {
	local path_system
	path_system=$(path_libraries)
	assert_not_empty 'path_system' 'launcher_native_libraries_paths'

	local path_user
	path_user='${HOME}/.local/lib/games/${GAME_ID}'

	cat <<- EOF
	# Set loading paths for libraries
	PLAYIT_LIBS_PATH_LEGACY="\$APP_LIBS"
	PLAYIT_LIBS_PATH_SYSTEM='${path_system}'
	PLAYIT_LIBS_PATH_USER="${path_user}"
	EOF
	cat <<- 'EOF'
	if [ -n "$PLAYIT_LIBS_PATH_LEGACY" ]; then
	    LD_LIBRARY_PATH="${PLAYIT_LIBS_PATH_LEGACY}:${LD_LIBRARY_PATH}"
	fi
	if [ -e "$PLAYIT_LIBS_PATH_SYSTEM" ]; then
	    LD_LIBRARY_PATH="${PLAYIT_LIBS_PATH_SYSTEM}:${LD_LIBRARY_PATH}"
	fi
	if [ -e "$PLAYIT_LIBS_PATH_USER" ]; then
	    LD_LIBRARY_PATH="${PLAYIT_LIBS_PATH_USER}:${LD_LIBRARY_PATH}"
	fi
	export LD_LIBRARY_PATH

	EOF
}
