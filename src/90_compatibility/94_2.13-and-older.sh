# Keep compatibility with 2.13 and older

use_archive_specific_value() {
	if version_is_at_least '2.14' "$target_version"; then
		warning_deprecated_function 'use_archive_specific_value' 'get_context_specific_value'
	fi

	export "$1=$(get_context_specific_value 'archive' "$1")"
}
