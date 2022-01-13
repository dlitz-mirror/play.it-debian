# extract the content of an archive using unzip
# USAGE: archive_extraction_using_unzip $archive $destination_directory
archive_extraction_using_unzip() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_unzip'
	assert_not_empty 'destination_directory' 'archive_extraction_using_unzip'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	debug_external_command "unzip -d \"$destination_directory\" \"$archive_path\" 1>/dev/null"
	unzip -d "$destination_directory" "$archive_path" 1>/dev/null
}
