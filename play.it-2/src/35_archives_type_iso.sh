# extract the content of an ISO9660 CD-ROM image
# USAGE: archive_extraction_iso $archive $destination_directory
archive_extraction_iso() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'bsdtar' >/dev/null 2>&1; then
		debug_external_command "bsdtar --directory \"$destination_directory\" --extract --file \"$archive_path\""
		bsdtar --directory "$destination_directory" --extract --file "$archive_path"
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'iso'
		return 1
	fi
}

