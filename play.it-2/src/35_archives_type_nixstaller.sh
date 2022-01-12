# extract the content of a Nixstaller installer (1st stage of extraction)
# USAGE: archive_extraction_nixstaller_stage1 $archive $destination_directory
archive_extraction_nixstaller_stage1() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if \
		command -v 'dd' >/dev/null 2>&1 \
		&& \
		command -v 'gunzip' >/dev/null 2>&1 \
		&& \
		command -v 'tar' >/dev/null 2>&1
	then
		local header_length input_blocksize
		header_length=$(grep --text 'offset=.*head.*wc' "$archive_path" | awk '{print $3}' | head --lines=1)
		input_blocksize=$(head --lines="$header_length" "$archive_path" | wc --bytes | tr --delete ' ')

		debug_external_command "dd if=\"$archive_path\" ibs=\"$input_blocksize\" skip=1 obs=1024 conv=sync 2>/dev/null | gunzip --stdout | tar --extract --file - --directory \"$destination_directory\""
		dd if="$archive_path" ibs=$input_blocksize skip=1 obs=1024 conv=sync 2>/dev/null | \
			gunzip --stdout | \
			tar --extract --file - --directory "$destination_directory"
	else
		error_archive_no_extractor_found 'nixstaller_stage1'
		return 1
	fi
}

# extract the content of a Nixstaller installer (2nd stage of extraction)
# USAGE: archive_extraction_nixstaller_stage2 $archive $destination_directory
archive_extraction_nixstaller_stage2() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'tar' >/dev/null 2>&1; then
		debug_external_command "tar --extract --xz --file \"$archive_path\" --directory \"$destination_directory\""
		tar --extract --xz --file "$archive_path" --directory "$destination_directory"
	else
		error_archive_no_extractor_found 'nixstaller_stage2'
		return 1
	fi
}

