# extract the content of an archive using msiextract
# USAGE: archive_extraction_using_msiextract $archive $destination_directory
archive_extraction_using_msiextract() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_msiextract'
	assert_not_empty 'destination_directory' 'archive_extraction_using_msiextract'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	debug_external_command "msiextract $extractor_options --directory \"$destination_directory\" \"$archive_path\" 1>/dev/null 2>&1"
	msiextract $extractor_options --directory "$destination_directory" "$archive_path" 1>/dev/null 2>&1
	tolower "$destination_directory"
}
