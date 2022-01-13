# extract the content of an archive using 7zr
# USAGE: archive_extraction_using_7zr $archive $destination_directory
archive_extraction_using_7zr() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_7zr'
	assert_not_empty 'destination_directory' 'archive_extraction_using_7zr'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options='-y'
	debug_external_command "7zr x $extractor_options -o\"$destination_directory\" \"$archive_path\" 1>/dev/null"
	7zr x $extractor_options -o"$destination_directory" "$archive_path" 1>/dev/null
}
