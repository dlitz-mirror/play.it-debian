# check the presence of required tools to handle a LHA archive (.lzh)
# USAGE: archive_dependencies_check_type_lha
archive_dependencies_check_type_lha() {
	local required_command
	for required_command in 'lha' 'bsdtar'; do
		if command -v "$required_command" >/dev/null 2>&1; then
			return 0
		fi
	done
	error_dependency_not_found 'lha'
	return 1
}

# extract the content of a LHA archive (.lzh)
# USAGE: archive_extraction_lha $archive $destination_directory
archive_extraction_lha() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_lha'
	assert_not_empty 'destination_directory' 'archive_extraction_lha'

	if command -v 'lha' >/dev/null 2>&1; then
		archive_extraction_using_lha "$archive" "$destination_directory"
	elif command -v 'bsdtar' >/dev/null 2>&1; then
		archive_extraction_using_bsdtar "$archive" "$destination_directory"
	else
		error_archive_no_extractor_found 'lha'
		return 1
	fi
}
