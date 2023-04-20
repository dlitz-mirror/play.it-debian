# ResidualVM - Print the content of the launcher script
# USAGE: residualvm_launcher $application
residualvm_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('none')
			residualvm_launcher_application_variables "$application"
			launcher_game_variables
			application_prerun "$application"
			residualvm_launcher_run
			application_postrun "$application"
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

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
