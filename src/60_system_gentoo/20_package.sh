# id of the single package built on egentoo
# USAGE: egentoo_package_id
egentoo_package_id() {
	game_id
}

# name of the single package built on egentoo
# USAGE: egentoo_package_name
egentoo_package_name() {
	assert_not_empty 'ARCHIVE' 'egentoo_package_name'
	printf '%s-%s' "$(egentoo_package_id)" "$(packages_get_version "$ARCHIVE")"
}
