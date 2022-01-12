# extract the content of a InnoSetup installer
# USAGE: archive_extraction_innosetup $archive $destination_directory
archive_extraction_innosetup() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'innoextract' >/dev/null 2>&1; then
		if ! archive_extraction_innosetup_is_supported "$archive_path"; then
			error_innoextract_version_too_old "$archive_path"
			return 1
		fi
		local archive_type extractor_options
		archive_type=$(archive_get_type "$archive")
		case "$archive_type" in
			('innosetup_nolowercase')
				extractor_options='--progress=1 --silent'
			;;
			(*)
				extractor_options='--progress=1 --silent --lowercase'
			;;
		esac
		debug_external_command "innoextract $extractor_options --extract --output-dir \"$destination_directory\" \"$archive_path\" 2>/dev/null"
		innoextract $extractor_options --extract --output-dir "$destination_directory" "$archive_path" 2>/dev/null
	else
		error_archive_no_extractor_found 'innosetup'
		return 1
	fi
}

# check that the InnoSetup archive can be processed by the available innoextract version
# USAGE: archive_extraction_innosetup_is_supported $archive_path
# RETURNS: 0 if supported, 1 if unsupported
archive_extraction_innosetup_is_supported() {
	local archive_path
	archive_path="$1"

	# Use innoextract internal check
	if innoextract --list --silent "$archive_path" 2>&1 1>/dev/null | \
		head --lines=1 | \
		grep --ignore-case --quiet 'unexpected setup data version'
	then
		return 1
	fi

	# Check for GOG archives based on Galaxy file fragments, unsupported by innoextract < 1.7
	if innoextract --list "$archive_path" | \
		grep --quiet ' - "tmp/[0-9a-f]\{2\}/[0-9a-f]\{2\}/[0-9a-f]\{32\}" (.*)'
	then
		return 1
	fi

	return 0
}

