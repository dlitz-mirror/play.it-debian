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
# USAGE: archive_extraction_rar $archive $destination_directory $log_file
archive_extraction_rar() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	if command -v 'unar' >/dev/null 2>&1; then
		archive_extraction_using_unar "$archive" "$destination_directory" "$log_file"
	else
		error_archive_no_extractor_found 'rar'
		return 1
	fi
}
