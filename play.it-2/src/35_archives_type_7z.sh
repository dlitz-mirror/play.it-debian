# extract the content of a 7z archive
# USAGE: archive_extraction_7z $archive_file $destination_directory
archive_extraction_7z() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v '7zr' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-y'
		debug_external_command "7zr x $extractor_options -o\"$destination_directory\" \"$archive_file\" 1>/dev/null"
		7zr x $extractor_options -o"$destination_directory" "$archive_file" 1>/dev/null
	elif command -v '7za' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-y'
		debug_external_command "7za x $extractor_options -o\"$destination_directory\" \"$archive_file\" 1>/dev/null"
		7za x $extractor_options -o"$destination_directory" "$archive_file" 1>/dev/null
	elif command -v 'unar' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-force-overwrite -no-directory'
		debug_external_command "unar $extractor_options -output-directory \"$destination_directory\" $extractor_options \"$archive_file\" 1>/dev/null"
		unar $extractor_options -output-directory "$destination_directory" "$archive_file" 1>/dev/null
	else
		error_archive_no_extractor_found '7z'
		return 1
	fi
}

