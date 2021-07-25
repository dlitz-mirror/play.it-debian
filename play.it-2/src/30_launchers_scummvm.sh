# ScummVM - write application-specific variables
# USAGE: launcher_write_script_scummvm_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_scummvm_application_variables() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- EOF
	# Set application-specific values

	SCUMMVM_ID='$(get_context_specific_value 'package' "${application}_SCUMMID")'

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

