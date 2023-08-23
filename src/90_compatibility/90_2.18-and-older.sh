# Keep compatibility with 2.18 and older

content_path_legacy() {
	context_value "ARCHIVE_${1}_PATH"
}

content_files_legacy() {
	local content_files_legacy
	content_files_legacy=$(context_value "ARCHIVE_${1}_FILES")

	# Legacy variable could use spaces as a delimiter,
	# line breaks are expected instead.
	local file_pattern
	for file_pattern in $content_files_legacy; do
		printf '%s\n' "$file_pattern"
	done
}
