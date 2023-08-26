# Print the default path to the game data in the archive
# USAGE: content_path_default
# RETURN: a path relative to the archive root
content_path_default() {
	local content_path
	content_path=$(context_value 'CONTENT_PATH_DEFAULT')

	if [ -z "$content_path" ]; then
		error_missing_variable 'CONTENT_PATH_DEFAULT'
		return 1
	fi

	printf '%s' "$content_path"
}

# Print the path to the game data in the archive for a given identifier
# USAGE: content_path $content_id
# RETURN: a path relative to the archive root
#         or an empty path if none is set
content_path() {
	local content_id
	content_id="$1"

	# Use the context-specific content path if available
	local content_path
	content_path=$(context_value "CONTENT_${content_id}_PATH")

	# Try to parse legacy variables for old game scripts
	if \
		[ -z "$content_path" ] \
		&& ! version_is_at_least '2.19' "$target_version"
	then
		content_path=$(content_path_legacy "$content_id")
	fi

	# Fall back to default content path if unset
	if [ -z "$content_path" ]; then
		# Do not fail if no default path is set
		content_path=$(content_path_default) 2>/dev/null || true
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

	local content_files
	content_files=$(context_value "CONTENT_${content_id}_FILES")

	# Try to parse legacy variables for old game scripts
	if \
		[ -z "$content_files" ] \
		&& ! version_is_at_least '2.19' "$target_version"
	then
		content_files=$(content_files_legacy "$content_id")
	fi

	# Fall back on default files lists for specific engines
	if [ -z "$content_files" ]; then
		## Unity3D
		local unity3d_name
		unity3d_name=$(unity3d_name)
		if [ -n "$unity3d_name" ]; then
			content_files=$(unity3d_content_files_default "$content_id")
		fi
		## Unreal Engine 4
		local unrealengine4_name
		unrealengine4_name=$(unrealengine4_name)
		if [ -n "$unrealengine4_name" ]; then
			content_files=$(unrealengine4_content_files_default "$content_id")
		fi
	fi

	printf '%s' "$content_files"
}

