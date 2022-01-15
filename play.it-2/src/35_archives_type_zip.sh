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

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'unzip' >/dev/null 2>&1; then
		debug_external_command "unzip -d \"$destination_directory\" \"$archive_path\" 1>/dev/null"
		unzip -d "$destination_directory" "$archive_path" 1>/dev/null
	else
		error_archive_no_extractor_found 'zip'
		return 1
	fi
}

# extract the content of a .zip archive (ignore errors)
# USAGE: archive_extraction_zip_unclean $archive $destination_directory
archive_extraction_zip_unclean() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'unzip' >/dev/null 2>&1; then
		debug_external_command "unzip -d \"$destination_directory\" \"$archive_path\" 1>/dev/null 2>&1"
		set +o errexit
		unzip -d "$destination_directory" "$archive_path" 1>/dev/null 2>&1
		set -o errexit
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'zip'
		return 1
	fi
}

