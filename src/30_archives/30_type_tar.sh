# check the presence of required tools to handle a tar archive
# USAGE: archive_dependencies_check_type_tar
archive_dependencies_check_type_tar() {
	if command -v 'tar' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'tar'
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
# USAGE: archive_extraction_tar $archive $destination_directory
archive_extraction_tar() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'tar' >/dev/null 2>&1; then
		debug_external_command "tar --extract --file \"$archive_path\" --directory \"$destination_directory\""
		tar --extract --file "$archive_path" --directory "$destination_directory"
	else
		error_archive_no_extractor_found 'tar'
		return 1
	fi
}

