# extract the content of an archive using lha
# USAGE: archive_extraction_using_lha $archive $destination_directory
archive_extraction_using_lha() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_lha'
	assert_not_empty 'destination_directory' 'archive_extraction_using_lha'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	# Due to its unusual command syntax, lha extractor has no support for ARCHIVE_xxx_EXTRACTOR_OPTIONS
	debug_external_command "lha -ew=\"$destination_directory\" \"$archive_path\" >/dev/null"
	lha -ew="$destination_directory" "$archive_path" >/dev/null
	set_standard_permissions "$destination_directory"
}
