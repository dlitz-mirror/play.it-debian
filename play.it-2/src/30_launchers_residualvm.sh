# ResidualVM - write application-specific variables
# USAGE: launcher_write_script_residualvm_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_residualvm_application_variables() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	# compute application-specific variables values
	local application_residualid
	use_package_specific_value "${application}_RESIDUALID"
	application_residualid="$(get_value "${application}_RESIDUALID")"

	cat >> "$file" <<- EOF
	# Set application-specific values

	RESIDUALVM_ID='$application_residualid'

	EOF
	return 0
}

# ResidualVM - run the game
# USAGE: launcher_write_script_residualvm_run $application $file
# CALLS: launcher_write_script_prerun launcher_write_script_postrun
# CALLED BY: launcher_write_script
launcher_write_script_residualvm_run() {
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
	residualvm -p "$PATH_GAME" $APP_OPTIONS $@ $RESIDUALVM_ID

	EOF

	launcher_write_script_postrun "$application" "$file"

	return 0
}

