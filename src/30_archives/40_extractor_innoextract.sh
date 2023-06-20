# extract the content of an archive using innoextract
# USAGE: archive_extraction_using_innoextract $archive $destination_directory $log_file
archive_extraction_using_innoextract() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"
	assert_not_empty 'archive' 'archive_extraction_using_innoextract'
	assert_not_empty 'destination_directory' 'archive_extraction_using_innoextract'
	assert_not_empty 'log_file' 'archive_extraction_using_innoextract'

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if ! archive_extraction_using_innoextract_is_supported "$archive_path"; then
		error_innoextract_version_too_old "$archive_path"
		return 1
	fi

	local extractor_options
	extractor_options=$(archive_extractor_options "$archive")
	if [ -z "$extractor_options" ]; then
		extractor_options='--lowercase'
	fi
	debug_external_command "innoextract $extractor_options --extract --output-dir \"$destination_directory\" \"$archive_path\" >> \"$log_file\" 2>&1"
	innoextract $extractor_options --extract --output-dir "$destination_directory" "$archive_path" >> "$log_file" 2>&1
}

# check that the InnoSetup archive can be processed by the available innoextract version
# USAGE: archive_extraction_using_innoextract_is_supported $archive_path
# RETURNS: 0 if supported, 1 if unsupported
archive_extraction_using_innoextract_is_supported() {
	local archive_path
	archive_path="$1"
	assert_not_empty 'archive_path' 'archive_extraction_using_innoextract_is_supported'

	# Use innoextract internal check
	if innoextract --list --silent "$archive_path" 2>&1 1>/dev/null | \
		head --lines=1 | \
		grep --ignore-case --quiet 'unexpected setup data version'
	then
		return 1
	fi

	# Check for GOG archives based on Galaxy file fragments, unsupported by innoextract < 1.7
	if innoextract --list "$archive_path" 2>/dev/null | \
		grep --quiet ' - "tmp/[0-9a-f]\{2\}/[0-9a-f]\{2\}/[0-9a-f]\{32\}" (.*)'
	then
		return 1
	fi

	return 0
}
