# Java - Print application-specific variables
# USAGE: java_launcher_application_variables $application
java_launcher_application_variables() {
	local application
	application="$1"

	local application_exe application_libs application_options application_java_options
	application_exe=$(application_exe_escaped "$application")
	application_libs=$(application_libs "$application")
	application_options=$(application_options "$application")
	application_java_options=$(application_java_options "$application")

	cat <<- EOF
	# Set application-specific values
	APP_EXE='$application_exe'
	APP_LIBS='$application_libs'
	APP_OPTIONS="$application_options"
	JAVA_OPTIONS='$application_java_options'
	EOF
}

# Java - Print the actual call to java
# USAGE: java_launcher_run $application
java_launcher_run() {
	local application
	application="$1"

	local application_prerun application_postrun launcher_native_libraries_paths
	application_prerun=$(application_prerun "$application")
	application_postrun=$(application_postrun "$application")
	launcher_native_libraries_paths=$(launcher_native_libraries_paths)

	cat <<- EOF
	# Run the game
	cd "\$PATH_PREFIX"
	$application_prerun
	$launcher_native_libraries_paths
	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit
	java \$JAVA_OPTIONS -jar "\$APP_EXE" \$APP_OPTIONS "\$@"
	game_exit_status=\$?
	set -o errexit
	$application_postrun
	EOF
}
