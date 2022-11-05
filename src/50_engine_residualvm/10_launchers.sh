# ResidualVM - Print application-specific variables
# USAGE: residualvm_launcher_application_variables $application
residualvm_launcher_application_variables() {
	local application
	application="$1"

	local application_residualid application_options
	application_residualid=$(application_residualvm_residualid "$application")
	application_options=$(application_options "$application")

	cat <<- EOF
	# Set application-specific values
	RESIDUALVM_ID='$application_residualid'
	APP_OPTIONS="$application_options"
	EOF
}

# ResidualVM - Print the actual call to residualvm
# USAGE: residualvm_launcher_run
residualvm_launcher_run() {
	cat <<- 'EOF'
	# Run the game
	residualvm --path="$PATH_GAME" $APP_OPTIONS "$@" "$RESIDUALVM_ID"
	EOF
}
