# extract the content of an archive using unar
# USAGE: archive_extraction_using_unar $archive $destination_directory
archive_extraction_using_unar() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_unar'
	assert_not_empty 'destination_directory' 'archive_extraction_using_unar'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options='-force-overwrite -no-directory'
	debug_external_command "unar $extractor_options -output-directory \"$destination_directory\" $extractor_options \"$archive_path\" 1>/dev/null"
	unar $extractor_options -output-directory "$destination_directory" "$archive_path" 1>/dev/null
}
