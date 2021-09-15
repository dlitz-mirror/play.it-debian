# print the Java options string for the given application
# USAGE: application_java_options $application
# RETURN: the options string on a single line,
#         or an empty string if no options are set
application_java_options() {
	# Check that the application uses the java type
	# shellcheck disable=SC2039
	local application application_type
	application_type=$(application_type "$application")
	if [ "$application_type" != 'java' ]; then
		error_application_wrong_type 'application_java_options' "$application_type"
		return 1
	fi

	# Get the application Java options string from its identifier
	# shellcheck disable=SC2039
	local application_java_options
	application_java_options=$(get_value "${application}_JAVA_OPTIONS")

	# Check that the options string does not span multiple lines
	if [ "$(printf '%s' "$application_java_options" | wc --lines)" -gt 1 ]; then
		error_variable_multiline "${application}_JAVA_OPTIONS"
		return 1
	fi

	printf '%s' "$application_java_options"
}

