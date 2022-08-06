# check the presence of required tools to handle a NullSoft installer
# USAGE: archive_dependencies_check_type_nullsoft
archive_dependencies_check_type_nullsoft() {
	if command -v 'unar' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'unar'
	return 1
}

# extract the content of a NullSoft installer
# USAGE: archive_extraction_nullsoft $archive $destination_directory
archive_extraction_nullsoft() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_nullsoft'
	assert_not_empty 'destination_directory' 'archive_extraction_nullsoft'

	if command -v 'unar' >/dev/null 2>&1; then
		archive_extraction_using_unar "$archive" "$destination_directory"
	else
		error_archive_no_extractor_found 'nullsoft-installer'
		return 1
	fi
}
