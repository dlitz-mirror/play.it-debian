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

	debug_external_command "tar --extract --file \"$archive_path\" --directory \"$destination_directory\""
	tar --extract --file "$archive_path" --directory "$destination_directory"
}
