# extract the content of a Microsoft Cabinet (.cab) archive
# USAGE: archive_extraction_cabinet $archive_file $destination_directory
archive_extraction_cabinet() {
	local archive_file destination_directory
	archive_file="$1"
	destination_directory="$2"

	if command -v 'cabextract' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-L -q'
		debug_external_command "cabextract $extractor_options -d \"$destination_directory\" \"$archive_file\""
		cabextract $extractor_options -d "$destination_directory" "$archive_file"
	else
		error_archive_no_extractor_found 'cabinet'
		return 1
	fi
}

