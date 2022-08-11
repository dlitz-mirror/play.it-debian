# Keep compatibility with 2.18 and older

content_path_legacy() {
	get_context_specific_value 'archive' "ARCHIVE_${1}_PATH"
}
