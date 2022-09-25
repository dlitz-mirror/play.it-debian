# Mono - write application-specific variables
# USAGE: launcher_write_script_mono_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_mono_application_variables() {
	local application file
	application="$1"
	file="$2"
	local application_exe application_libs application_options application_mono_options
	application_exe=$(application_exe_escaped "$application")
	application_libs=$(application_libs "$application")
	application_options=$(application_options "$application")
	application_mono_options=$(application_mono_options "$application")

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$application_exe'
	APP_LIBS='$application_libs'
	APP_OPTIONS="$application_options"
	MONO_OPTIONS='$application_mono_options'

	EOF
	return 0
}

# Mono - run the game
# USAGE: launcher_write_script_mono_run $application $file
# CALLED BY: launcher_write_script
launcher_write_script_mono_run() {
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
	# Work around terminfo Mono bug, cf. https://github.com/mono/mono/issues/6752
	export TERM="${TERM%-256color}"

	# Work around Mono unpredictable behaviour with non-US locales
	export LANG=C

	MONO_OPTIONS="$(eval printf -- '%b' \"$MONO_OPTIONS\")"
	mono $MONO_OPTIONS "$APP_EXE" $APP_OPTIONS "$@"

	EOF

	launcher_write_script_postrun "$application" "$file"

	sed --in-place 's/    /\t/g' "$file"
	return 0
}

