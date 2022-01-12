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

