# Keep compatibility with 2.13 and older

use_archive_specific_value() {
	# WARNING - Context limitation to archive is ignored.

	if version_is_at_least '2.14' "$target_version"; then
		warning_deprecated_function 'use_archive_specific_value' 'context_value'
	fi

	export "$1=$(context_value "$1")"
}
