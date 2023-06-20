# extract the content of an archive using 7za
# USAGE: archive_extraction_using_7za $archive $destination_directory $log_file
archive_extraction_using_7za() {
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
	printf '7za x %s -o"%s" "%s"\n' "$extractor_options" "$destination_directory" "$archive_path" >> "$log_file"
	7za x $extractor_options -o"$destination_directory" "$archive_path" >> "$log_file" 2>&1
}
