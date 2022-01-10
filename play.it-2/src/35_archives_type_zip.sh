# extract the content of a .zip archive
# USAGE: archive_extraction_zip $archive_file $destination_directory
archive_extraction_zip() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'unzip' >/dev/null 2>&1; then
		debug_external_command "unzip -d \"$destination_directory\" \"$archive_file\" 1>/dev/null"
		unzip -d "$destination_directory" "$archive_file" 1>/dev/null
	else
		error_archive_no_extractor_found 'zip'
		return 1
	fi
}

# extract the content of a .zip archive (ignore errors)
# USAGE: archive_extraction_zip_unclean $archive_file $destination_directory
archive_extraction_zip_unclean() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'unzip' >/dev/null 2>&1; then
		debug_external_command "unzip -d \"$destination_directory\" \"$archive_file\" 1>/dev/null 2>&1"
		set +o errexit
		unzip -d "$destination_directory" "$archive_file" 1>/dev/null 2>&1
		set -o errexit
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'zip'
		return 1
	fi
}

