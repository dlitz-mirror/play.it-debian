# check the presence of required tools to handle a Microsoft Cabinet (.cab) archive
# USAGE: archive_dependencies_check_type_cabinet
archive_dependencies_check_type_cabinet() {
	if command -v 'cabextract' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'cabextract'
	return 1
}

# extract the content of a Microsoft Cabinet (.cab) archive
# USAGE: archive_extraction_cabinet $archive $destination_directory $log_file
archive_extraction_cabinet() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	if command -v 'cabextract' >/dev/null 2>&1; then
		archive_extraction_using_cabextract "$archive" "$destination_directory" "$log_file"
	else
		error_archive_no_extractor_found 'cabinet'
		return 1
	fi
}
