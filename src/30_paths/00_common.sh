# Print install path for binaries.
# USAGE: path_binaries
path_binaries() {
	local install_prefix target_system path_structure
	install_prefix=$(option_value 'prefix')
	target_system=$(option_value 'package')
	case "$target_system" in
		('deb')
			# Debian uses /usr/games as the default path for game-related binaries.
			path_structure='%s/games'
		;;
		(*)
			# Non-Debian systems use /usr/bin as the default path for all binaries,
			# including game-related ones.
			path_structure='%s/bin'
		;;
	esac
	printf "$path_structure" "$install_prefix"
}

# Print install path for XDG .desktop menu entries.
# USAGE: path_xdg_desktop
path_xdg_desktop() {
	# For convenience, XDG .desktop menu entries are always installed under the default install prefix.
	# If they could be installed under a custom path like /opt/${game_id},
	# they would not be picked up by applications menus without a manual intervention from the system administrator.
	local default_install_prefix
	default_install_prefix=$(option_value_default 'prefix')
	printf '%s/share/applications' "$default_install_prefix"
}

# Print install path for documentation files.
# USAGE: path_documentation
path_documentation() {
	local install_prefix option_package
	install_prefix=$(option_value 'prefix')
	option_package=$(option_value 'package')
	case "$option_package" in
		('deb'|'arch')
			local game_id
			game_id=$(game_id)
			printf '%s/share/doc/%s' "$install_prefix" "$game_id"
			;;
		('gentoo'|'egentoo')
			local package_name
			package_name=$(egentoo_package_name)
			printf '%s/share/doc/%s' "$install_prefix" "$package_name"
			;;
	esac
}

# Print install path for game files.
# USAGE: path_game_data
path_game_data() {
	local install_prefix game_id target_system path_structure
	install_prefix=$(option_value 'prefix')
	game_id=$(game_id)
	target_system=$(option_value 'package')
	case "$target_system" in
		('deb')
			# Debian uses /usr/share/games as the default path for game-related data files.
			path_structure='%s/share/games/%s'
		;;
		(*)
			# Non-Debian systems use /usr/share as the default path for all data files,
			# including game-related ones.
			path_structure='%s/share/%s'
		;;
	esac
	printf "$path_structure" "$install_prefix" "$game_id"
}

# Print install path for icons.
# USAGE: path_icons
path_icons() {
	# Icons are always installed under the default install prefix.
	# launcher_desktop (src/30_launchers/00_common.sh) expects the icon to be available under either /usr or /usr/local.
	local default_install_prefix
	default_install_prefix=$(option_value_default 'prefix')
	printf '%s/share/icons/hicolor' "$default_install_prefix"
}

# Print install path for native libraries.
# USAGE: path_libraries
path_libraries() {
	local install_prefix game_id
	install_prefix=$(option_value 'prefix')
	game_id=$(game_id)
	printf '%s/lib/games/%s' "$install_prefix" "$game_id"
}
