# print the Java options string for the given application
# USAGE: application_java_options $application
# RETURN: the options string on a single line,
#         or an empty string if no options are set
application_java_options() {
	# Check that the application uses the java type
	local application application_type
	application="$1"
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
	if [ "$application_type" != 'java' ]; then
		error_application_wrong_type 'application_java_options' "$application_type"
		return 1
	fi

	# Get the application Java options string from its identifier
	local application_java_options
	if variable_is_empty "${application}_JAVA_OPTIONS"; then
		# Return early if no options string is set.
		return 0
	else
		application_java_options=$(get_value "${application}_JAVA_OPTIONS")
	fi

	# Check that the options string does not span multiple lines
	if [ "$(printf '%s' "$application_java_options" | wc --lines)" -gt 1 ]; then
		error_variable_multiline "${application}_JAVA_OPTIONS"
		return 1
	fi

	printf '%s' "$application_java_options"
}

