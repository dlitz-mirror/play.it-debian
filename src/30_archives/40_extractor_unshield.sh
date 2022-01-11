# extract the content of an archive using unshield
# USAGE: archive_extraction_using_unshield $archive $destination_directory
archive_extraction_using_unshield() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_unshield'
	assert_not_empty 'destination_directory' 'archive_extraction_using_unshield'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	if [ -z "$extractor_options" ]; then
		extractor_options='-L'
	fi
	debug_external_command "unshield $extractor_options -d \"$destination_directory\" x \"$archive_path\" >/dev/null"
	unshield $extractor_options -d "$destination_directory" x "$archive_path" >/dev/null
}

