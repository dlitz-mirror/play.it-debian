# extract the content of an InstallShield installer
# USAGE: archive_extraction_installshield $archive_file $destination_directory
archive_extraction_installshield() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'unshield' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-L'
		debug_external_command "unshield $extractor_options -d \"$destination_directory\" x \"$archive_file\" >/dev/null"
		unshield $extractor_options -d "$destination_directory" x "$archive_file" >/dev/null
	else
		error_archive_no_extractor_found 'installshield'
		return 1
	fi
}

