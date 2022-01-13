# extract the content of an archive using cabextract
# USAGE: archive_extraction_using_cabextract $archive $destination_directory
archive_extraction_using_cabextract() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_cabextract'
	assert_not_empty 'destination_directory' 'archive_extraction_using_cabextract'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options='-L -q'
	debug_external_command "cabextract $extractor_options -d \"$destination_directory\" \"$archive_path\""
	cabextract $extractor_options -d "$destination_directory" "$archive_path"
}
