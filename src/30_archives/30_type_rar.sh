# check the presence of required tools to handle a RAR archive
# USAGE: archive_dependencies_check_type_rar
archive_dependencies_check_type_rar() {
	if command -v 'unar' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'unar'
	return 1
}

# extract the content of a RAR archive
# USAGE: archive_extraction_rar $archive $destination_directory
archive_extraction_rar() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_rar'
	assert_not_empty 'destination_directory' 'archive_extraction_rar'

	if command -v 'unar' >/dev/null 2>&1; then
		archive_extraction_using_unar "$archive" "$destination_directory"
	else
		error_archive_no_extractor_found 'rar'
		return 1
	fi
}
