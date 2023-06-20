# extract the content of an archive using 7za
# USAGE: archive_extraction_using_7za $archive $destination_directory $log_file
archive_extraction_using_7za() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"
	assert_not_empty 'archive' 'archive_extraction_using_7za'
	assert_not_empty 'destination_directory' 'archive_extraction_using_7za'
	assert_not_empty 'log_file' 'archive_extraction_using_7za'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	if [ -z "$extractor_options" ]; then
		extractor_options='-y'
	fi
	debug_external_command "7za x $extractor_options -o\"$destination_directory\" \"$archive_path\" >> \"$log_file\" 2>&1"
	7za x $extractor_options -o"$destination_directory" "$archive_path" >> "$log_file" 2>&1
}
