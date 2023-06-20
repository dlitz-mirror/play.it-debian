# check the presence of required tools to handle a InnoSetup installer
# USAGE: archive_dependencies_check_type_innosetup
archive_dependencies_check_type_innosetup() {
	if command -v 'innoextract' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'innoextract'
	return 1
}

# extract the content of a InnoSetup installer
# USAGE: archive_extraction_innosetup $archive $destination_directory $log_file
archive_extraction_innosetup() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"
	assert_not_empty 'archive' 'archive_extraction_innosetup'
	assert_not_empty 'destination_directory' 'archive_extraction_innosetup'
	assert_not_empty 'log_file' 'archive_extraction_innosetup'

	if command -v 'innoextract' >/dev/null 2>&1; then
		archive_extraction_using_innoextract "$archive" "$destination_directory" "$log_file"
	else
		error_archive_no_extractor_found 'innosetup'
		return 1
	fi
}
