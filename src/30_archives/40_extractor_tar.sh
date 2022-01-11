# extract the content of an archive using tar
# USAGE: archive_extraction_using_tar $archive $destination_directory
archive_extraction_using_tar() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_tar'
	assert_not_empty 'destination_directory' 'archive_extraction_using_tar'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	debug_external_command "tar $extractor_options --extract --file \"$archive_path\" --directory \"$destination_directory\""
	tar $extractor_options --extract --file "$archive_path" --directory "$destination_directory"
}
