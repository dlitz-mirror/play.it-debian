# Keep compatibility with 2.12 and older

archives_get_list() {
	ARCHIVES_LIST=$(archives_return_list)
	export ARCHIVES_LIST
}

get_package_version() {
	PKG_VERSION=$(packages_get_version "$ARCHIVE")
	export PKG_VERSION
}

set_architecture() {
	pkg_architecture=$(package_get_architecture_string "$1")
	export pkg_architecture
}

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

version_target_is_older_than() {
	if [ "$1" = "${VERSION_MAJOR_TARGET}.${VERSION_MINOR_TARGET}" ]; then
		return 1
	fi
	version_is_at_least "${VERSION_MAJOR_TARGET}.${VERSION_MINOR_TARGET}" "$1"
}

