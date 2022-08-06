# Keep compatibility with 2.11 and older

liberror() {
	error_invalid_argument "$1" "$2"
	return 1
}
