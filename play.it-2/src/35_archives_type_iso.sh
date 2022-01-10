# extract the content of an ISO9660 CD-ROM image
# USAGE: archive_extraction_iso $archive_file $destination_directory
archive_extraction_iso() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'bsdtar' >/dev/null 2>&1; then
		debug_external_command "bsdtar --directory \"$destination_directory\" --extract --file \"$archive_file\""
		bsdtar --directory "$destination_directory" --extract --file "$archive_file"
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'iso'
		return 1
	fi
}

