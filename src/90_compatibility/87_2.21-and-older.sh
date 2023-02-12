# Keep compatibility with 2.21 and older

packages_get_version() {
	if version_is_at_least '2.22' "$target_version"; then
		warning_deprecated_function 'packages_get_version' 'package_version'
	fi

	(
		ARCHIVE="$1"
		package_version
	)
}
