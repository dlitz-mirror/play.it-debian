# ScummVM - Print the content of the launcher script
# USAGE: scummvm_launcher $application
scummvm_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('none')
			scummvm_launcher_application_variables "$application"
			launcher_game_variables
			application_prerun "$application"
			scummvm_launcher_run
			application_postrun "$application"
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

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
