# extract the content of a MojoSetup MakeSelf installer
# USAGE: archive_extraction_mojosetup $archive_file $destination_directory
archive_extraction_mojosetup() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'bsdtar' >/dev/null 2>&1; then
		debug_external_command "bsdtar --directory \"$destination_directory\" --extract --file \"$archive_file\""
		bsdtar --directory "$destination_directory" --extract --file "$archive_file"
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'mojosetup'
		return 1
	fi
}

# extract the content of a MojoSetup MakeSelf installer (using unzip)
# USAGE: archive_extraction_mojosetup_unzip $archive_file $destination_directory
archive_extraction_mojosetup_unzip() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'unzip' >/dev/null 2>&1; then
		set +o errexit
		debug_external_command "unzip -d \"$destination_directory\" \"$archive_file\" 1>/dev/null 2>&1"
		unzip -d "$destination_directory" "$archive_file" 1>/dev/null 2>&1
		set -o errexit
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'mojosetup'
		return 1
	fi
}

