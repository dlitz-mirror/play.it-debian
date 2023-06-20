# extract the content of an archive using unar
# USAGE: archive_extraction_using_unar $archive $destination_directory $log_file
archive_extraction_using_unar() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"
	assert_not_empty 'archive' 'archive_extraction_using_unar'
	assert_not_empty 'destination_directory' 'archive_extraction_using_unar'
	assert_not_empty 'log_file' 'archive_extraction_using_unar'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	if [ -z "$extractor_options" ]; then
		extractor_options='-force-overwrite -no-directory'
	fi
	debug_external_command "unar $extractor_options -output-directory \"$destination_directory\" $extractor_options \"$archive_path\" >> \"$log_file\" 2>&1"
	unar $extractor_options -output-directory "$destination_directory" "$archive_path" >> "$log_file" 2>&1
}
