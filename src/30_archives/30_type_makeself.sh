# List the requirements to extract the contents of a Makeself installer
# USAGE: archive_requirements_makeself_list
archive_requirements_makeself_list() {
	printf '%s\n' \
		'head' \
		'sed' \
		'wc' \
		'tr' \
		'gzip' \
		'tar'
}

# Check the presence of required tools to handle a Makeself installer
# USAGE: archive_requirements_makeself_check
archive_requirements_makeself_check() {
	local commands_list required_command
	commands_list=$(archive_requirements_makeself_list)
	for required_command in $commands_list; do
		if ! command -v "$required_command" >/dev/null 2>&1; then
			error_dependency_not_found "$required_command"
			return 1
		fi
	done
}

# Extract the content of a Makeself installer
# USAGE: archive_extraction_makeself $archive $destination_directory $log_file
archive_extraction_makeself() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	# Fetch the archive properties
	local archive_offset archive_filesize archive_block_size archive_blocks archive_bytes
	archive_offset=$(makeself_offset "$archive_path")
	archive_filesize=$(makeself_filesize "$archive_path")
	## Arbitrary value, small values would increase the time spent on the dd calls.
	archive_block_size=4096
	archive_blocks=$((archive_filesize / archive_block_size))
	archive_bytes=$((archive_filesize % archive_block_size))

	# Proceed with the contents extraction
	local archive_extraction_return_code
	{
		printf 'dd if="%s" ibs="%s" skip=1 obs=%s conv=sync 2>/dev/null | ' "$archive_path" "$archive_offset" "$archive_block_size"
		printf '{ test "%s" -gt 0 && dd ibs=%s obs=%s count="%s" ; ' "$archive_blocks" "$archive_block_size" "$archive_block_size" "$archive_blocks"
		printf 'test "%s" -gt 0 && dd ibs=1 obs=%s count="%s" ; } 2>/dev/null | ' "$archive_bytes" "$archive_block_size" "$archive_bytes"
		printf 'gzip --stdout --decompress | tar xvf - --directory="%s"\n' "$destination_directory"
	} >> "$log_file"
	{
		dd if="$archive_path" ibs="$archive_offset" skip=1 obs="$archive_block_size" conv=sync 2>/dev/null | \
			{
				test "$archive_blocks" -gt 0 && dd ibs="$archive_block_size" obs="$archive_block_size" count="$archive_blocks"
				test "$archive_bytes" -gt 0 && dd ibs=1 obs="$archive_block_size" count="$archive_bytes"
			} 2>/dev/null | \
			gzip --stdout --decompress | \
			tar xvf - --directory="$destination_directory" >> "$log_file" 2>&1
		archive_extraction_return_code=$?
	} || true
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi
}

# Makeself - Get the offset of the given file
# USAGE: makeself_offset $archive_path
# RETURN: the archive offset
makeself_offset() {
	local archive_path
	archive_path="$1"

	local archive_header_length archive_offset
	archive_header_length=$( \
		head --lines=200 "$archive_path" | \
		sed --silent 's/^\s*offset=`head -n \([0-9]\+\) "$1" | wc -c | tr -d " "`\s*/\1/p' \
	)
	archive_offset=$( \
		head --lines="$archive_header_length" "$archive_path" | \
		wc --bytes | \
		tr --delete ' ' \
	)

	printf '%s' "$archive_offset"
}

# Makeself - Get the size of the archive included in the given file
# USAGE: makeself_filesize $archive_path
# RETURN: the archive file size
makeself_filesize() {
	local archive_path
	archive_path="$1"

	local archive_filesize
	archive_filesize=$( \
		head --lines=200 "$archive_path" | \
		sed --silent 's/^\s*filesizes="\([0-9]\+\)"\s*/\1/p' \
	)

	printf '%s' "$archive_filesize"
}

