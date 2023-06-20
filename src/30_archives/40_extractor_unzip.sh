# extract the content of an archive using unzip
# USAGE: archive_extraction_using_unzip $archive $destination_directory $log_file
archive_extraction_using_unzip() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	debug_external_command "unzip $extractor_options -d \"$destination_directory\" \"$archive_path\" >> \"$log_file\" 2>&1"
	unzip $extractor_options -d "$destination_directory" "$archive_path" >> "$log_file" 2>&1
}
