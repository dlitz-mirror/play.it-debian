# Ren'Py - Print the content of the launcher script
# USAGE: renpy_launcher $application
renpy_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			launcher_game_variables
			launcher_print_persistent_paths
			launcher_prefix_symlinks_functions
			launcher_prefix_symlinks_build
			renpy_launcher_run "$application"
			launcher_prefix_symlinks_cleanup
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

# Ren'Py - Print the actual call to the game binary
# USAGE: renpy_launcher_run $application
renpy_launcher_run() {
	local application
	application="$1"

	local application_prerun application_postrun
	application_prerun=$(application_prerun "$application")
	application_postrun=$(application_postrun "$application")

	cat <<- EOF
	# Run the game
	cd "\$PATH_PREFIX"
	$application_prerun
	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit
	renpy . "\$@"
	game_exit_status=\$?
	set -o errexit
	$application_postrun
	EOF
}
