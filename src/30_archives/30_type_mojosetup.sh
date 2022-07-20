# check the presence of required tools to handle a MojoSetup MakeSelf installer
# USAGE: archive_dependencies_check_type_mojosetup
archive_dependencies_check_type_mojosetup() {
	if command -v 'bsdtar' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'bsdtar'
	return 1
}

# check the presence of required tools to handle a MojoSetup MakeSelf installer (using unzip)
# USAGE: archive_dependencies_check_type_mojosetup_unzip
archive_dependencies_check_type_mojosetup_unzip() {
	# WARNING - This function is deprecated.
	if command -v 'unzip' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'unzip'
	return 1
}

# extract the content of a MojoSetup MakeSelf installer
# USAGE: archive_extraction_mojosetup $archive $destination_directory
archive_extraction_mojosetup() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_mojosetup'
	assert_not_empty 'destination_directory' 'archive_extraction_mojosetup'

	if command -v 'bsdtar' >/dev/null 2>&1; then
		archive_extraction_using_bsdtar "$archive" "$destination_directory"
	else
		error_archive_no_extractor_found 'mojosetup'
		return 1
	fi
}

# extract the content of a MojoSetup MakeSelf installer (using unzip)
# USAGE: archive_extraction_mojosetup_unzip $archive $destination_directory
archive_extraction_mojosetup_unzip() {
	# WARNING - This function is deprecated.
	local archive destination_directory
	archive="$1"
	destination_directory="$2"
	assert_not_empty 'archive' 'archive_extraction_mojosetup_unzip'
	assert_not_empty 'destination_directory' 'archive_extraction_mojosetup_unzip'

	if command -v 'unzip' >/dev/null 2>&1; then
		set +o errexit
		archive_extraction_using_unzip "$archive" "$destination_directory" 2>/dev/null
		set -o errexit
		set_standard_permissions "$destination_directory"
	else
		error_archive_no_extractor_found 'mojosetup'
		return 1
	fi
}
