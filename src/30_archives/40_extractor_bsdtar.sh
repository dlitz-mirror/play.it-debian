# extract the content of an archive using bsdtar
# USAGE: archive_extraction_using_bsdtar $archive $destination_directory $log_file
archive_extraction_using_bsdtar() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	printf 'bsdtar --verbose %s --directory "%s" --extract --file "%s"\n' "$extractor_options" "$destination_directory" "$archive_path" >> "$log_file"
	local archive_extraction_return_code
	set +o errexit
	bsdtar --verbose $extractor_options --directory "$destination_directory" --extract --file "$archive_path" >> "$log_file" 2>&1
	archive_extraction_return_code=$?
	set -o errexit
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi
}
