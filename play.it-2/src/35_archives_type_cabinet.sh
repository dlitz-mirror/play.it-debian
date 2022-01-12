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
# USAGE: archive_extraction_cabinet $archive $destination_directory
archive_extraction_cabinet() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'cabextract' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-L -q'
		debug_external_command "cabextract $extractor_options -d \"$destination_directory\" \"$archive_path\""
		cabextract $extractor_options -d "$destination_directory" "$archive_path"
	else
		error_archive_no_extractor_found 'cabinet'
		return 1
	fi
}

