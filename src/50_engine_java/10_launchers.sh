# Java - write application-specific variables
# USAGE: launcher_write_script_java_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_java_application_variables() {
	local application file
	application="$1"
	file="$2"
	local application_exe application_libs application_options application_java_options
	application_exe=$(application_exe_escaped "$application")
	application_libs=$(application_libs "$application")
	application_options=$(application_options "$application")
	application_java_options=$(application_java_options "$application")

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$application_exe'
	APP_LIBS='$application_libs'
	APP_OPTIONS="$application_options"
	JAVA_OPTIONS='$application_java_options'

	EOF
	return 0
}

# Java - run the game
# USAGE: launcher_write_script_java_run $application $file
# CALLED BY: launcher_write_script
launcher_write_script_java_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF

	launcher_write_script_prerun "$application" "$file"

	# Set loading paths for libraries
	launcher_native_libraries_paths >> "$file"

	cat >> "$file" <<- 'EOF'
	JAVA_OPTIONS="$(eval printf -- '%b' \"$JAVA_OPTIONS\")"
	java $JAVA_OPTIONS -jar "$APP_EXE" $APP_OPTIONS "$@"

	EOF

	launcher_write_script_postrun "$application" "$file"

	sed --in-place 's/    /\t/g' "$file"
	return 0
}

