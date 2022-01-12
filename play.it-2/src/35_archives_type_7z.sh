# check the presence of required tools to handle a 7z archive
# USAGE: archive_dependencies_check_type_7z
archive_dependencies_check_type_7z() {
	local required_command
	for required_command in '7zr' '7za' 'unar'; do
		if command -v "$required_command" >/dev/null 2>&1; then
			return 0
		fi
	done
	error_dependency_not_found '7zr'
	return 1
}

# extract the content of a 7z archive
# USAGE: archive_extraction_7z $archive $destination_directory
archive_extraction_7z() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v '7zr' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-y'
		debug_external_command "7zr x $extractor_options -o\"$destination_directory\" \"$archive_path\" 1>/dev/null"
		7zr x $extractor_options -o"$destination_directory" "$archive_path" 1>/dev/null
	elif command -v '7za' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-y'
		debug_external_command "7za x $extractor_options -o\"$destination_directory\" \"$archive_path\" 1>/dev/null"
		7za x $extractor_options -o"$destination_directory" "$archive_path" 1>/dev/null
	elif command -v 'unar' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-force-overwrite -no-directory'
		debug_external_command "unar $extractor_options -output-directory \"$destination_directory\" $extractor_options \"$archive_path\" 1>/dev/null"
		unar $extractor_options -output-directory "$destination_directory" "$archive_path" 1>/dev/null
	else
		error_archive_no_extractor_found '7z'
		return 1
	fi
}

