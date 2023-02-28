# Keep compatibility with 2.20 and older

archives_return_list_legacy() {
	local variable_name_pattern
	variable_name_pattern='^ARCHIVE_[0-9A-Z]\+\(_OLD[0-9A-Z]*\)*='
	set | \
		grep --regexp="$variable_name_pattern" | \
		cut --delimiter='=' --fields=1
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
