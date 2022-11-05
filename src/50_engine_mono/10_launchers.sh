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

	cat <<- EOF
	# Run the game
	cd "\$PATH_PREFIX"
	$(application_prerun "$application")
	$(launcher_native_libraries_paths)
	$(mono_launcher_tweaks)
    ## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit
	mono \$MONO_OPTIONS "\$APP_EXE" \$APP_OPTIONS "\$@"
	game_exit_status=\$?
	set -o errexit
	$(application_postrun "$application")
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
