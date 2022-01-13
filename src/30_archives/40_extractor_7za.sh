# extract the content of an archive using 7za
# USAGE: archive_extraction_using_7za $archive $destination_directory
archive_extraction_using_7za() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_7za'
	assert_not_empty 'destination_directory' 'archive_extraction_using_7za'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options='-y'
	debug_external_command "7za x $extractor_options -o\"$destination_directory\" \"$archive_path\" 1>/dev/null"
	7za x $extractor_options -o"$destination_directory" "$archive_path" 1>/dev/null
}
