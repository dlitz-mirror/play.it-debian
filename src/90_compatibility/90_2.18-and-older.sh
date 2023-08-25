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

application_libs_legacy() {
	local application
	application="$1"

	local application_libs
	application_libs=$(context_value "${application}_LIBS")
	# The deprecation warning should only be shown if the legacy variable is actually used.
	if \
		[ -n "$application_libs" ] && \
		version_is_at_least '2.19' "$target_version"
	then
		warning_deprecated_variable "${application}_LIBS" 'CONTENT_LIBS_xxx_PATH / CONTENT_LIBS_xxx_FILES'
	fi
	printf '%s' "$application_libs"
}

