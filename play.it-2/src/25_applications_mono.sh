# print the Mono options string for the given application
# USAGE: application_mono_options $application
# RETURN: the options string on a single line,
#         or an empty string if no options are set
application_mono_options() {
	# Check that the application uses the mono type
	# shellcheck disable=SC2039
	local application application_type
	application_type=$(application_type "$application")
	if [ "$application_type" != 'mono' ]; then
		error_application_wrong_type 'application_mono_options' "$application_type"
		return 1
	fi

	# Get the application Mono options string from its identifier
	# shellcheck disable=SC2039
	local application_mono_options
	application_mono_options=$(get_value "${application}_MONO_OPTIONS")

	# Check that the options string does not span multiple lines
	if [ "$(printf '%s' "$application_mono_options" | wc --lines)" -gt 1 ]; then
		error_variable_multiline "${application}_MONO_OPTIONS"
		return 1
	fi

	printf '%s' "$application_mono_options"
}

