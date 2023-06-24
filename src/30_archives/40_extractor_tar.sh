# extract the content of an archive using tar
# USAGE: archive_extraction_using_tar $archive $destination_directory $log_file
archive_extraction_using_tar() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	printf 'tar --verbose %s --extract --file "%s" --directory "%s"\n' "$extractor_options" "$archive_path" "$destination_directory" >> "$log_file"
	local archive_extraction_return_code
	set +o errexit
	tar --verbose $extractor_options --extract --file "$archive_path" --directory "$destination_directory" >> "$log_file" 2>&1
	archive_extraction_return_code=$?
	set -o errexit
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi
}
