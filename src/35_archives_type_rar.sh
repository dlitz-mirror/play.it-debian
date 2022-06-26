# check the presence of required tools to handle a RAR archive
# USAGE: archive_dependencies_check_type_rar
archive_dependencies_check_type_rar() {
	if command -v 'unar' >/dev/null 2>&1; then
		return 0
	fi
	error_dependency_not_found 'unar'
	return 1
}

# extract the content of a RAR archive
# USAGE: archive_extraction_rar $archive $destination_directory
archive_extraction_rar() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'unar' >/dev/null 2>&1; then
		local extractor_options
		extractor_options='-no-directory'
	
		###
		# TODO
		# This should be handled by adding the ability for game scripts to pass options to unar.
		###
		# compute archive password from GOG id
		local archive_gog_id extractor_options
		archive_gog_id=$(get_value "${archive}_GOGID")
		if [ -n "$archive_gog_id" ]; then
			local archive_password
			archive_password=$(printf '%s' "$archive_gog_id" | md5sum | cut --delimiter=' ' --fields=1)
			extractor_options="$extractor_options -password $archive_password"
		fi
	
		debug_external_command "unar $extractor_options -output-directory \"$destination_directory\" \"$archive_path\" 1>/dev/null"
		unar $extractor_options -output-directory "$destination_directory" "$archive_path" 1>/dev/null
	else
		error_archive_no_extractor_found 'rar'
		return 1
	fi
}

