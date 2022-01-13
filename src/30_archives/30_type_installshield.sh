# check the presence of required tools to handle an InstallShield installer
# USAGE: archive_dependencies_check_type_installshield
archive_dependencies_check_type_installshield() {
	if command -v 'unshield' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'unshield'
	return 1
}

# extract the content of an InstallShield installer
# USAGE: archive_extraction_installshield $archive $destination_directory
archive_extraction_installshield() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_installshield'
	assert_not_empty 'destination_directory' 'archive_extraction_installshield'

	if command -v 'unshield' >/dev/null 2>&1; then
		archive_extraction_using_unshield "$archive" "$destination_directory"
	else
		error_archive_no_extractor_found 'installshield'
		return 1
	fi
}
