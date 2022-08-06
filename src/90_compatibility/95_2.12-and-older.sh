# Keep compatibility with 2.12 and older

icons_linking_postinst() {
	if \
		! version_is_at_least '2.8' "$target_version" && \
		packages_get_list | grep --quiet --fixed-strings 'PKG_DATA'
	then
		(
			PKG='PKG_DATA'
			icons_get_from_package "$@"
		)
	else
		icons_get_from_package "$@"
	fi
}

archive_set() {
	archive_initialize_optional "$@"
	local archive
	archive=$(archive_find_from_candidates "$@")
	if [ -n "$archive" ]; then
		ARCHIVE="$archive"
		export ARCHIVE
	fi
}

