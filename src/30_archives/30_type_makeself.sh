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
# USAGE: archive_extraction_makeself $archive $destination_directory
archive_extraction_makeself() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	# Fetch the archive properties
	local archive_header_length archive_offset archive_filesize archive_block_size archive_blocks archive_bytes
	archive_header_length=$( \
		head --lines=200 "$archive_path" | \
		sed --silent 's/^\s*offset=`head -n \([0-9]\+\) "$1" | wc -c | tr -d " "`\s*/\1/p' \
	)
	archive_offset=$(head --lines="$archive_header_length" "$archive_path" | wc --bytes | tr --delete ' ')
	archive_filesize=$( \
		head --lines=200 "$archive_path" | \
		sed --silent 's/^\s*filesizes="\([0-9]\+\)"\s*/\1/p' \
	)
	archive_block_size=1024
	archive_blocks=$((archive_filesize / archive_block_size))
	archive_bytes=$((archive_filesize % archive_block_size))

	# Proceed with the contents extraction
	dd if="$archive_path" ibs="$archive_offset" skip=1 obs=1024 conv=sync 2>/dev/null | \
		{
			test "$archive_blocks" -gt 0 && dd ibs=1024 obs=1024 count="$archive_blocks" ; \
			test "$archive_bytes" -gt 0 && dd ibs=1 obs=1024 count="$archive_bytes" ;
		} 2>/dev/null | \
		gzip --stdout --decompress | \
		tar xf - --directory="$destination_directory"

	# Apply minimal permissions on extracted files
	set_standard_permissions "$destination_directory"
}
