# extract the content of an archive using 7zr
# USAGE: archive_extraction_using_7zr $archive $destination_directory $log_file
archive_extraction_using_7zr() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"
	assert_not_empty 'archive' 'archive_extraction_using_7zr'
	assert_not_empty 'destination_directory' 'archive_extraction_using_7zr'
	assert_not_empty 'log_file' 'archive_extraction_using_7zr'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	if [ -z "$extractor_options" ]; then
		extractor_options='-y'
	fi
	debug_external_command "7zr x $extractor_options -o\"$destination_directory\" \"$archive_path\" >> \"$log_file\" 2>&1"
	7zr x $extractor_options -o"$destination_directory" "$archive_path" >> "$log_file" 2>&1
}
