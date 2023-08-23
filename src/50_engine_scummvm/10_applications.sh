# Print the ScummVM id for the given application
# USAGE: application_scummvm_scummid $application
# RETURN: the ScummVM id, or an empty string if none is set
application_scummvm_scummid() {
	local application
	application="$1"

	# Get the application ScummVM id from its identifier
	local application_scummid
	application_scummid=$(context_value "${application}_SCUMMID")

	# Return early if no ScummVM id is set
	if [ -z "$application_scummid" ]; then
		return 0
	fi

	# Check that the id fits the ScummVM id format
	# Allowed formats are:
	# - "engine:game"
	# - "game"
	if ! printf '%s' "$application_scummid" | \
		grep --quiet --regexp='^\([0-9a-z]\+:\)\?[0-9a-z]\+$'
	then
		error_application_scummid_invalid "$application" "$application_scummid"
		return 1
	fi

	printf '%s' "$application_scummid"
}

