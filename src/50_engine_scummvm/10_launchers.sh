# ScummVM launcher - Print the script content
# USAGE: scummvm_launcher $application
scummvm_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('none')
			launcher_headers
			scummvm_launcher_environment "$application"
			scummvm_launcher_run
			launcher_exit
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

# ScummVM launcher - Set the environment
# USAGE: scummvm_launcher_environment $application
scummvm_launcher_environment() {
	local application
	application="$1"

	local path_game application_scummid application_options
	path_game=$(path_game_data)
	application_scummid=$(application_scummvm_scummid "$application")
	application_options=$(application_options "$application")

	cat <<- EOF
	# Set the environment

	PATH_GAME='$path_game'
	SCUMMVM_ID='$application_scummid'
	APP_OPTIONS="$application_options"

	EOF
}

# ScummVM launcher - Run ScummVM
# USAGE: scummvm_launcher_run
scummvm_launcher_run() {
	cat <<- 'EOF'
	# Run the game

	EOF

	application_prerun "$application"

	cat <<- 'EOF'
	## Silence ShellCheck false-positive
	## Double quote to prevent globbing and word splitting.
	# shellcheck disable=SC2086
	scummvm --path="$PATH_GAME" $APP_OPTIONS "$@" "$SCUMMVM_ID"

	EOF

	application_postrun "$application"
}
