# Keep compatibility with 2.20 and older

package_get_current() {
	if version_is_at_least '2.21' "$target_version"; then
		warning_deprecated_function 'package_get_current' 'context_package'
	fi

	context_package
}
