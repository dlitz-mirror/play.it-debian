# Keep compatibility with 2.19 and older

dosbox_prerun_legacy() {
	local application
	application="$1"

	get_value "${application}_PRERUN"
}

dosbox_postrun_legacy() {
	local application
	application="$1"

	get_value "${application}_POSTRUN"
}

package_get_path() {
	if version_is_at_least '2.20' "$target_version"; then
		warning_deprecated_function 'package_get_path' 'package_path'
	fi

	package_path "$1"
}
