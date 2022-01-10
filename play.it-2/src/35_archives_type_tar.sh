# extract the content of a .tar archive
# USAGE: archive_extraction_tar $archive_file $destination_directory
archive_extraction_tar() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'tar' >/dev/null 2>&1; then
		debug_external_command "tar --extract --file \"$archive_file\" --directory \"$destination_directory\""
		tar --extract --file "$archive_file" --directory "$destination_directory"
	else
		error_archive_no_extractor_found 'tar'
		return 1
	fi
}

