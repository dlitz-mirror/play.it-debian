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
