# extract the content of an archive using lha
# USAGE: archive_extraction_using_lha $archive $destination_directory $log_file
archive_extraction_using_lha() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local archive_extraction_return_code
	# Due to its unusual command syntax, lha extractor has no support for ARCHIVE_xxx_EXTRACTOR_OPTIONS
	printf 'lha -ew="%s" "%s"\n' "$destination_directory" "$archive_path" >> "$log_file"
	{
		lha -ew="$destination_directory" "$archive_path" >> "$log_file" 2>&1
		archive_extraction_return_code=$?
	} || true
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi
}

