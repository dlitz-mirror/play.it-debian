# extract the content of an archive using dpkg-deb
# USAGE: archive_extraction_using_dpkgdeb $archive $destination_directory $log_file
archive_extraction_using_dpkgdeb() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options archive_extraction_return_code
	extractor_options=$(archive_extractor_options "$archive")
	printf 'dpkg-deb --verbose %s --extract "%s" "%s"\n' "$extractor_options" "$archive_path" "$destination_directory" >> "$log_file"
	{
		dpkg-deb --verbose $extractor_options --extract "$archive_path" "$destination_directory" >> "$log_file" 2>&1
		archive_extraction_return_code=$?
	} || true
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi
}

