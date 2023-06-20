# check the presence of required tools to handle a Windows Installer (.msi)
# USAGE: archive_dependencies_check_type_msi
archive_dependencies_check_type_msi() {
	if command -v 'msiextract' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'msiextract'
	return 1
}

# extract the content of a Windows Installer (.msi)
# USAGE: archive_extraction_msi $archive $destination_directory $log_file
archive_extraction_msi() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	if command -v 'msiextract' >/dev/null 2>&1; then
		archive_extraction_using_msiextract "$archive" "$destination_directory" "$log_file"
	else
		error_archive_no_extractor_found 'msi'
		return 1
	fi
}
