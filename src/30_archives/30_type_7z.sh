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
	assert_not_empty 'archive' 'archive_extraction_7z'
	assert_not_empty 'destination_directory' 'archive_extraction_7z'

	if command -v '7zr' >/dev/null 2>&1; then
		archive_extraction_using_7zr "$archive" "$destination_directory"
	elif command -v '7za' >/dev/null 2>&1; then
		archive_extraction_using_7za "$archive" "$destination_directory"
	elif command -v 'unar' >/dev/null 2>&1; then
		archive_extraction_using_unar "$archive" "$destination_directory"
	else
		error_archive_no_extractor_found '7z'
		return 1
	fi
}
