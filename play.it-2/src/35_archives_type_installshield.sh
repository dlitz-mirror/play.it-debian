# extract the content of an InstallShield installer
# USAGE: archive_extraction_installshield $archive $destination_directory
archive_extraction_installshield() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'unshield' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-L'
		debug_external_command "unshield $extractor_options -d \"$destination_directory\" x \"$archive_path\" >/dev/null"
		unshield $extractor_options -d "$destination_directory" x "$archive_path" >/dev/null
	else
		error_archive_no_extractor_found 'installshield'
		return 1
	fi
}

