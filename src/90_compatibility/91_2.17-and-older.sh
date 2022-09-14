# Keep compatibility with 2.17 and older

organize_data() {
	local package
	package=$(package_get_current)
	content_inclusion "$1" "$package" "$2"
}

prepare_package_layout() {
	content_inclusion_default
}
