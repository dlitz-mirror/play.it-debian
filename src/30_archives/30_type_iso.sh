# check the presence of required tools to handle an ISO9660 CD-ROM image
# USAGE: archive_dependencies_check_type_iso
archive_dependencies_check_type_iso() {
	if command -v 'bsdtar' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'bsdtar'
	return 1
}

# extract the content of an ISO9660 CD-ROM image
# USAGE: archive_extraction_iso $archive $destination_directory
archive_extraction_iso() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_iso'
	assert_not_empty 'destination_directory' 'archive_extraction_iso'

	if command -v 'bsdtar' >/dev/null 2>&1; then
		archive_extraction_using_bsdtar "$archive" "$destination_directory"
	else
		error_archive_no_extractor_found 'iso'
		return 1
	fi
}
