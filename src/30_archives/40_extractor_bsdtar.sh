# extract the content of an archive using bsdtar
# USAGE: archive_extraction_using_bsdtar $archive $destination_directory
archive_extraction_using_bsdtar() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_bsdtar'
	assert_not_empty 'destination_directory' 'archive_extraction_using_bsdtar'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	debug_external_command "bsdtar --directory \"$destination_directory\" --extract --file \"$archive_path\""
	bsdtar --directory "$destination_directory" --extract --file "$archive_path"
	set_standard_permissions "$destination_directory"
}
