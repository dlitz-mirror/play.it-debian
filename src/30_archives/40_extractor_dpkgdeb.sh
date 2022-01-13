# extract the content of an archive using dpkg-deb
# USAGE: archive_extraction_using_dpkgdeb $archive $destination_directory
archive_extraction_using_dpkgdeb() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_using_dpkgdeb'
	assert_not_empty 'destination_directory' 'archive_extraction_using_dpkgdeb'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	debug_external_command "dpkg-deb --extract \"$archive_path\" \"$destination_directory\""
	dpkg-deb --extract "$archive_path" "$destination_directory"
}
