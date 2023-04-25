# Keep compatibility with 2.23 and older

wine_persistent_legacy() {
	# Return early if APP_WINE_LINK_DIRS is not set
	if variable_is_empty 'APP_WINE_LINK_DIRS'; then
		return 0
	fi

	cat <<- EOF
	# Move files that should be diverted to persistent paths to the game directory
	APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"
	EOF
	cat <<- 'EOF'
	printf '%s' "$APP_WINE_LINK_DIRS" | grep ':' | while read -r line; do
	    prefix_dir="$PATH_PREFIX/${line%%:*}"
	    wine_dir="$WINEPREFIX/drive_c/${line#*:}"
	    mkdir --parents "$prefix_dir"
	    if [ ! -h "$wine_dir" ]; then
	        if [ -d "$wine_dir" ]; then
	            # A basic recursive cp will not work due to the presence of symbolic links to directories in the destination.
	            (
	                cd "$prefix_dir"
	                find . -type l
	            ) | while read -r link; do
	                if [ -e "${wine_dir}/${link}" ]; then
	                    cp --no-clobber --recursive "${wine_dir}/${link}"/* "${prefix_dir}/${link}"/
	                    rm --force --recursive "${wine_dir:?}/${link}"
	                fi
	            done
	            cp --no-clobber --no-target-directory --recursive "$wine_dir" "$prefix_dir"
	            rm --force --recursive "$wine_dir"
	        fi
	        if [ ! -d "$prefix_dir" ]; then
	            mkdir --parents "$prefix_dir"
	        fi
	        mkdir --parents "$(dirname "$wine_dir")"
	        ln --symbolic "$prefix_dir" "$wine_dir"
	    fi
	done
	EOF
}

write_metadata() {
	if version_is_at_least '2.24' "$target_version"; then
		warning_deprecated_function 'write_metadata' 'packages_generation'
	fi

	# If not explicit packages list is given, write metadata for all packages
	if [ $# -eq 0 ]; then
		local packages_list
		packages_list=$(packages_get_list)
		write_metadata $packages_list
	fi

	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			archlinux_packages_metadata "$@"
		;;
		('deb')
			debian_packages_metadata "$@"
		;;
		('gentoo')
			gentoo_packages_metadata "$@"
		;;
		('egentoo')
			egentoo_packages_metadata "$@"
		;;
	esac
}

build_pkg() {
	if version_is_at_least '2.24' "$target_version"; then
		warning_deprecated_function 'build_pkg' 'packages_generation'
	fi

	# If not explicit packages list is given, build all packages
	if [ $# -eq 0 ]; then
		local packages_list
		packages_list=$(packages_get_list)
		build_pkg $packages_list
	fi

	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			archlinux_packages_build "$@"
		;;
		('deb')
			debian_packages_build "$@"
		;;
		('gentoo')
			gentoo_packages_build "$@"
		;;
		('egentoo')
			egentoo_packages_build "$@"
		;;
	esac
}
