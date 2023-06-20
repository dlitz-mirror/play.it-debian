# check the presence of required tools to handle a Debian package (.deb)
# USAGE: archive_dependencies_check_type_debian
archive_dependencies_check_type_debian() {
	if command -v 'dpkg-deb' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'dpkg-deb'
	return 1
}

# extract the content of a Debian package (.deb)
# USAGE: archive_extraction_debian $archive $destination_directory $log_file
archive_extraction_debian() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"
	assert_not_empty 'archive' 'archive_extraction_debian'
	assert_not_empty 'destination_directory' 'archive_extraction_debian'
	assert_not_empty 'log_file' 'archive_extraction_debian'

	if command -v 'dpkg-deb' >/dev/null 2>&1; then
		archive_extraction_using_dpkgdeb "$archive" "$destination_directory" "$log_file"
	else
		error_archive_no_extractor_found 'debian'
		return 1
	fi
}
