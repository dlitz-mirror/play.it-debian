# check the presence of required tools to handle a tar archive
# USAGE: archive_dependencies_check_type_tar
archive_dependencies_check_type_tar() {
	if command -v 'tar' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'tar'
	return 1
}

# check the presence of required tools to handle a tar.bz2 archive
# USAGE: archive_dependencies_check_type_tarbz2
archive_dependencies_check_type_tarbz2() {
	archive_dependencies_check_type_tar
	if command -v 'bunzip2' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'bunzip2'
	return 1
}

# check the presence of required tools to handle a tar.gz archive
# USAGE: archive_dependencies_check_type_targz
archive_dependencies_check_type_targz() {
	archive_dependencies_check_type_tar
	if command -v 'gunzip' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'gunzip'
	return 1
}

# check the presence of required tools to handle a tar.xz archive
# USAGE: archive_dependencies_check_type_tarxz
archive_dependencies_check_type_tarxz() {
	archive_dependencies_check_type_tar
	if command -v 'unxz' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'unxz'
	return 1
}

# extract the content of a .tar archive
# USAGE: archive_extraction_tar $archive $destination_directory $log_file
archive_extraction_tar() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"
	assert_not_empty 'archive' 'archive_extraction_tar'
	assert_not_empty 'destination_directory' 'archive_extraction_tar'
	assert_not_empty 'log_file' 'archive_extraction_tar'

	if command -v 'tar' >/dev/null 2>&1; then
		archive_extraction_using_tar "$archive" "$destination_directory" "$log_file"
	else
		error_archive_no_extractor_found 'tar'
		return 1
	fi
}
