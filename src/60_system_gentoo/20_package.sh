# id of the single package built on egentoo
# USAGE: egentoo_package_id
egentoo_package_id() {
	game_id
}

# name of the single package built on egentoo
# USAGE: egentoo_package_name
egentoo_package_name() {
	# archive context is required to get the package version
	assert_not_empty 'ARCHIVE' 'egentoo_package_name'

	local archive package_id package_version
	archive=$(context_archive)
	package_id=$(egentoo_package_id)
	package_version=$(packages_get_version "$archive")
	printf '%s-%s' "$package_id" "$package_version"
}
