# check the presence of required tools to handle a LHA archive (.lzh)
# USAGE: archive_dependencies_check_type_lha
archive_dependencies_check_type_lha() {
	local required_command
	for required_command in 'lha' 'bsdtar'; do
		if command -v "$required_command" >/dev/null 2>&1; then
			return 0
		fi
	done
	error_dependency_not_found 'lha'
	return 1
}

# extract the content of a LHA archive (.lzh)
# USAGE: archive_extraction_lha $archive $destination_directory $log_file
archive_extraction_lha() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	if command -v 'lha' >/dev/null 2>&1; then
		archive_extraction_using_lha "$archive" "$destination_directory" "$log_file"
	elif command -v 'bsdtar' >/dev/null 2>&1; then
		archive_extraction_using_bsdtar "$archive" "$destination_directory" "$log_file"
	else
		error_archive_no_extractor_found 'lha'
		return 1
	fi
}
