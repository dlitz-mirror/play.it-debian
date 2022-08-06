# check the presence of required tools to handle a .zip archive
# USAGE: archive_dependencies_check_type_zip
archive_dependencies_check_type_zip() {
	if command -v 'unzip' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'unzip'
	return 1
}

# extract the content of a .zip archive
# USAGE: archive_extraction_zip $archive $destination_directory
archive_extraction_zip() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_zip'
	assert_not_empty 'destination_directory' 'archive_extraction_zip'

	if command -v 'unzip' >/dev/null 2>&1; then
		archive_extraction_using_unzip "$archive" "$destination_directory"
	else
		error_archive_no_extractor_found 'zip'
		return 1
	fi
}

# extract the content of a .zip archive (ignore errors)
# USAGE: archive_extraction_zip_unclean $archive $destination_directory
archive_extraction_zip_unclean() {
	# WARNING - This function is deprecated.
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_zip_unclean'
	assert_not_empty 'destination_directory' 'archive_extraction_zip_unclean'

	if command -v 'unzip' >/dev/null 2>&1; then
		set +o errexit
		archive_extraction_using_unzip "$archive" "$destination_directory" 2>/dev/null
		set -o errexit
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'zip'
		return 1
	fi
}
