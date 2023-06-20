# extract the content of an archive using unshield
# USAGE: archive_extraction_using_unshield $archive $destination_directory $log_file
archive_extraction_using_unshield() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	if [ -z "$extractor_options" ]; then
		extractor_options='-L'
	fi
	printf 'unshield %s -d "%s" x "%s"\n' "$extractor_options" "$destination_directory" "$archive_path" >> "$log_file"
	unshield $extractor_options -d "$destination_directory" x "$archive_path" >> "$log_file" 2>&1
}

