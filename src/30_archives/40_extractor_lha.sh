# extract the content of an archive using lha
# USAGE: archive_extraction_using_lha $archive $destination_directory $log_file
archive_extraction_using_lha() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	# Due to its unusual command syntax, lha extractor has no support for ARCHIVE_xxx_EXTRACTOR_OPTIONS
	debug_external_command "lha -ew=\"$destination_directory\" \"$archive_path\" >> \"$log_file\" 2>&1"
	lha -ew="$destination_directory" "$archive_path" >> "$log_file" 2>&1
}
