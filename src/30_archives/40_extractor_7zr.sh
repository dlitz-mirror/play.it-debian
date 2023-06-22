# extract the content of an archive using 7zr
# USAGE: archive_extraction_using_7zr $archive $destination_directory $log_file
archive_extraction_using_7zr() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	if [ -z "$extractor_options" ]; then
		extractor_options='-y'
	fi
	printf '7zr x %s -o"%s" "%s"\n' "$extractor_options" "$destination_directory" "$archive_path" >> "$log_file"
	local archive_extraction_return_code
	set +o errexit
	7zr x $extractor_options -o"$destination_directory" "$archive_path" >> "$log_file" 2>&1
	archive_extraction_return_code=$?
	set -o errexit
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi
}
