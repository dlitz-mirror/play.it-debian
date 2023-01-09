# Keep compatibility with 2.17 and older

organize_data() {
	if version_is_at_least '2.18' "$target_version"; then
		warning_deprecated_function 'organize_data' 'content_inclusion'
	fi

	local package
	package=$(package_get_current)
	content_inclusion "$1" "$package" "$2"
}

prepare_package_layout() {
	if version_is_at_least '2.18' "$target_version"; then
		warning_deprecated_function 'prepare_package_layout' 'content_inclusion_default'
	fi

	content_inclusion_default
}
