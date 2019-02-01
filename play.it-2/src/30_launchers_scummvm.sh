# ScummVM - write application-specific variables
# USAGE: launcher_write_script_scummvm_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_scummvm_application_variables() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	# compute application-specific variables values
	local application_scummid
	use_package_specific_value "${application}_SCUMMID"
	application_scummid="$(get_value "${application}_SCUMMID")"

	cat >> "$file" <<- EOF
	# Set application-specific values

	SCUMMVM_ID='$application_scummid'

	EOF
	return 0
}

# ScummVM - run the game
# USAGE: launcher_write_script_scummvm_run $application $file
# CALLS: launcher_write_script_prerun launcher_write_script_postrun
# CALLED BY: launcher_write_script
launcher_write_script_scummvm_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	EOF

	launcher_write_script_prerun "$application" "$file"

	cat >> "$file" <<- 'EOF'
	scummvm -p "$PATH_GAME" $APP_OPTIONS $@ $SCUMMVM_ID

	EOF

	launcher_write_script_postrun "$application" "$file"

	return 0
}

