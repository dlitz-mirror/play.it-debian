# Keep compatibility with 2.6.0 and older

set_archive() {
	archive_set "$@"
}

set_archive_error_not_found() {
	archive_set_error_not_found "$@"
	return 1
}

