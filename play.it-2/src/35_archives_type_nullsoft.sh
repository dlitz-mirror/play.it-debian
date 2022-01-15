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
# USAGE: archive_extraction_nullsoft $archive $destination_directory
archive_extraction_nullsoft() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'unar' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-no-directory'
		debug_external_command "unar $extractor_options -output-directory \"$destination_directory\" \"$archive_path\" 1>/dev/null"
		unar $extractor_options -output-directory "$destination_directory" "$archive_path" 1>/dev/null
	else
		error_archive_no_extractor_found 'nullsoft-installer'
		return 1
	fi
}

