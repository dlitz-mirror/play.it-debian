# extract the content of an archive using msiextract
# USAGE: archive_extraction_using_msiextract $archive $destination_directory $log_file
archive_extraction_using_msiextract() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options archive_extraction_return_code
	extractor_options=$(archive_extractor_options "$archive")
	printf 'msiextract %s --directory "%s" "%s"\n' "$extractor_options" "$destination_directory" "$archive_path" >> "$log_file"
	{
		msiextract $extractor_options --directory "$destination_directory" "$archive_path" >> "$log_file" 2>&1
		archive_extraction_return_code=$?
	} || true
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi
	tolower "$destination_directory"
}

