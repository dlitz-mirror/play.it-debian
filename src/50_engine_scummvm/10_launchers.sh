# ScummVM - Print application-specific variables
# USAGE: scummvm_launcher_application_variables $application
scummvm_launcher_application_variables() {
	local application
	application="$1"

	local application_scummid application_options
	application_scummid=$(application_scummvm_scummid "$application")
	application_options=$(application_options "$application")

	cat <<- EOF
	# Set application-specific values
	SCUMMVM_ID='$application_scummid'
	APP_OPTIONS="$application_options"
	EOF
}

# ScummVM - Print the actual call to scummvm
# USAGE: scummvm_launcher_run
scummvm_launcher_run() {
	cat <<- 'EOF'
	# Run the game
	scummvm --path="$PATH_GAME" $APP_OPTIONS "$@" "$SCUMMVM_ID"
	EOF
}
