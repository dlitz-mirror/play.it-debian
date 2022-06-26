# print the default path to the game data in the archive
# USAGE: content_path_default
# RETURN: a relative path
content_path_default() {
	# Use the archive-specific content path if available
	local content_path
	content_path=$(get_context_specific_value 'archive' 'CONTENT_PATH_DEFAULT')

	# Throw an error if no default content path is set by the game script
	if [ -z "$content_path" ]; then
		error_no_content_path_default
		return 1
	fi

	printf '%s' "$content_path"
}

