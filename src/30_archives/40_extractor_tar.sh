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
	debug_external_command "tar --verbose $extractor_options --extract --file \"$archive_path\" --directory \"$destination_directory\" >> \"$log_file\" 2>&1"
	tar --verbose $extractor_options --extract --file "$archive_path" --directory "$destination_directory" >> "$log_file" 2>&1
}
