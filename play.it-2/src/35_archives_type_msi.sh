# extract the content of a Windows Installer (.msi)
# USAGE: archive_extraction_msi $archive_file $destination_directory
archive_extraction_msi() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'msiextract' >/dev/null 2>&1; then
		debug_external_command "msiextract --directory \"$destination_directory\" \"$archive_file\" 1>/dev/null 2>&1"
		msiextract --directory "$destination_directory" "$archive_file" 1>/dev/null 2>&1
		tolower "$destination_directory"
	else
		error_archive_no_extractor_found 'msi'
		return 1
	fi
}

