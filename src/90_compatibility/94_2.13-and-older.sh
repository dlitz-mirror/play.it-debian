# Keep compatibility with 2.13 and older

use_archive_specific_value() {
	export "$1=$(get_context_specific_value 'archive' "$1")"
}
