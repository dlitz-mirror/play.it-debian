# Linux native - Print the content of the launcher script
# USAGE: native_launcher $application
native_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			launcher_headers
			native_launcher_application_variables "$application"
			launcher_game_variables
			launcher_print_persistent_paths
			launcher_prefix_symlinks_functions
			launcher_prefix_symlinks_build
			native_launcher_run "$application"
			launcher_prefix_symlinks_cleanup
			launcher_exit
		;;
		('none')
			launcher_headers
			native_launcher_application_variables "$application"
			launcher_game_variables
			native_launcher_run "$application"
			launcher_exit
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

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
			native_launcher_binary_copy

			# Work around Unity3D poor support for non-US locales
			launcher_unity3d_force_locale

			# Unity3D 4.x and 5.x - Disable the MAP_32BIT flag to prevent a crash one some Linux versions when running a 64-bit build
			local unity3d_version
			unity3d_version=$(unity3d_version)
			case "$unity3d_version" in
				('4.'*|'5.'*)
					local package package_architecture
					package=$(context_package)
					package_architecture=$(package_architecture "$package")
					if [ "$package_architecture" = '64' ]; then
						unity3d_disable_map32bit
					fi
				;;
			esac
		;;
		(*)
			# Make a hard copy of the game binary in the current prefix,
			# otherwise the engine might follow the link and run the game from the system path.
			local prefix_type
			prefix_type=$(application_prefix_type "$application")
			case "$prefix_type" in
				('symlinks')
					native_launcher_binary_copy
				;;
			esac
		;;
	esac

	# Set loading paths for libraries
	launcher_native_libraries_paths

	application_prerun "$application"

	cat <<- 'EOF'

	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit
	## Silence ShellCheck false-positive
	## Double quote to prevent globbing and word splitting.
	# shellcheck disable=SC2086
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
# USAGE: native_launcher_binary_copy
native_launcher_binary_copy() {
	{
		cat <<- 'EOF'
		# Copy the game binary into the user prefix
		exe_destination="${PATH_PREFIX}/${APP_EXE}"
		if [ -h "$exe_destination" ]; then
		    exe_source=$(realpath "$exe_destination")
		    cp --remove-destination "$exe_source" "$exe_destination"
		fi

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
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
	{
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
	} | sed --regexp-extended 's/( ){4}/\t/g'
}
