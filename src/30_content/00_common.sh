# Print the default path to the game data in the archive
# USAGE: content_path_default
# RETURN: a path relative to the archive root
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

# Print the path to the game data in the archive for a given identifier
# USAGE: content_path $content_id
# RETURN: a path relative to the archive root
content_path() {
	local content_id
	content_id="$1"

	# Use the archive-specific content path if available
	local content_path
	content_path=$(get_context_specific_value 'archive' "CONTENT_${content_id}_PATH")

	# Try to parse legacy variables for old game scripts
	if \
		[ -z "$content_path" ] \
		&& ! version_is_at_least '2.19' "$target_version"
	then
		content_path=$(content_path_legacy "$content_id")
	fi

	# Fall back to default content path if unset
	if [ -z "$content_path" ]; then
		content_path=$(content_path_default)
	fi

	printf '%s' "$content_path"
}

# Print the list of files to include from the archive for a given identifier
# USAGE: content_files $content_id
# RETURN: a list of paths relative to the path for the given identifier,
#         line breaks are used as separator between each item,
#         this list can include globbing patterns,
#         this list can be empty
content_files() {
	local content_id
	content_id="$1"

	# Use the archive-specific files list if available
	local content_files
	content_files=$(get_context_specific_value 'archive' "CONTENT_${content_id}_FILES")

	# Try to parse legacy variables for old game scripts
	if \
		[ -z "$content_files" ] \
		&& ! version_is_at_least '2.19' "$target_version"
	then
		content_files=$(content_files_legacy "$content_id")
	fi

	printf '%s' "$content_files"
}
