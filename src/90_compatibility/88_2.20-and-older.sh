# Keep compatibility with 2.20 and older

package_get_current() {
	if version_is_at_least '2.21' "$target_version"; then
		warning_deprecated_function 'package_get_current' 'context_package'
	fi

	context_package
}

context_archive_suffix_legacy() {
	local archive
	archive=$(context_archive)

	if \
		version_is_at_least '2.13' "$target_version" \
		&& [ "${archive#ARCHIVE_BASE}" != "$archive" ]
	then
		printf '%s' "${archive#ARCHIVE_BASE}"
	else
		printf '%s' "${archive#ARCHIVE}"
	fi
}

context_specific_value() {
	# WARNING - Context limitation to either archive or package is ignored.

	if version_is_at_least '2.21' "$target_version"; then
		warning_deprecated_function 'context_specific_value' 'context_value'
	fi

	context_value "$2"
}

get_context_specific_value() {
	# WARNING - Context limitation to either archive or package is ignored.

	if version_is_at_least '2.21' "$target_version"; then
		warning_deprecated_function 'get_context_specific_value' 'context_value'
	fi

	context_value "$2"
}
