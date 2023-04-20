# Mono - Print the content of the launcher script
# USAGE: mono_launcher $application
mono_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			launcher_headers
			mono_launcher_application_variables "$application"
			launcher_game_variables
			launcher_print_persistent_paths
			launcher_prefix_symlinks_functions
			launcher_prefix_symlinks_build
			mono_launcher_run "$application"
			launcher_prefix_symlinks_cleanup
			launcher_exit
		;;
		('none')
			launcher_headers
			mono_launcher_application_variables "$application"
			launcher_game_variables
			mono_launcher_run "$application"
			launcher_exit
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

# Mono - Print application-specific variables
# USAGE: mono_launcher_application_variables $application
mono_launcher_application_variables() {
	local application
	application="$1"

	local application_exe application_libs application_options application_mono_options
	application_exe=$(application_exe_escaped "$application")
	application_libs=$(application_libs "$application")
	application_options=$(application_options "$application")
	application_mono_options=$(application_mono_options "$application")

	cat <<- EOF
	# Set application-specific values
	APP_EXE='$application_exe'
	APP_LIBS='$application_libs'
	APP_OPTIONS="$application_options"
	MONO_OPTIONS='$application_mono_options'
	EOF
}

# Mono - Print the actual call to mono
# USAGE: mono_launcher_run $application
mono_launcher_run() {
	local application
	application="$1"

	local exec_path application_prerun application_postrun libraries_paths launcher_tweaks
	exec_path=$(mono_launcher_exec_path "$application")
	application_prerun=$(application_prerun "$application")
	application_postrun=$(application_postrun "$application")
	libraries_paths=$(launcher_native_libraries_paths)
	launcher_tweaks=$(mono_launcher_tweaks)

	cat <<- EOF
	# Run the game
	cd "$exec_path"
	$application_prerun
	$libraries_paths
	$launcher_tweaks
	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit
	mono \$MONO_OPTIONS "\$APP_EXE" \$APP_OPTIONS "\$@"
	game_exit_status=\$?
	set -o errexit
	$application_postrun
	EOF
}

# Mono - Print common workarounds
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

# Mono - Print the path from where the game binary is called.
# USAGE: mono_launcher_exec_path $application
mono_launcher_exec_path() {
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
