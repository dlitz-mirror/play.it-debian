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
# USAGE: archive_extraction_nullsoft $archive $destination_directory $log_file
archive_extraction_nullsoft() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	if command -v 'unar' >/dev/null 2>&1; then
		archive_extraction_using_unar "$archive" "$destination_directory" "$log_file"
	else
		error_archive_no_extractor_found 'nullsoft-installer'
		return 1
	fi
}
