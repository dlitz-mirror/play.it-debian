# print the ResidualVM id for the given application
# USAGE: application_residualvm_residualid $application
# RETURN: the ResidualVM id
application_residualvm_residualid() {
	# Check that the application uses the residualvm type
	# shellcheck disable=SC2039
	local application application_type
	application_type=$(application_type "$application")
	if [ "$application_type" != 'residualvm' ]; then
		error_application_wrong_type 'application_residualvm_residualid' "$application_type"
		return 1
	fi

	# Get the application ResidualVM id from its identifier
	# shellcheck disable=SC2039
	local application_residualid
	application_residualid=$(get_value "${application}_RESIDUALID")

	# Check that the id fits the ResidualVM id format
	if ! printf '%s' "$application_residualid" | \
		grep --quiet --regexp='^[0-9a-z]\+$'
	then
		error_application_residualid_invalid "$application" "$application_residualid"
		return 1
	fi

	printf '%s' "$application_residualid"
}

