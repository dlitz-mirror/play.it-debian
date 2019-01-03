# Keep compatibility with 2.11 and older

compat_pkg_write_arch_postinst() {
	local target
	target="$1"
	cat >> "$target" <<- EOF
	post_install() {
	$(cat "$postinst")
	}

	post_upgrade() {
	post_install
	}
	EOF
}

compat_pkg_write_arch_prerm() {
	local target
	target="$1"
	cat >> "$target" <<- EOF
	pre_remove() {
	$(cat "$prerm")
	}

	pre_upgrade() {
	pre_remove
	}
	EOF
}

compat_pkg_write_deb_postinst() {
	local target
	target="$1"
	cat > "$target" <<- EOF
	#!/bin/sh -e

	$(cat "$postinst")

	exit 0
	EOF
	chmod 755 "$target"
}

compat_pkg_write_deb_prerm() {
	local target
	target="$1"
	cat > "$target" <<- EOF
	#!/bin/sh -e

	$(cat "$prerm")

	exit 0
	EOF
	chmod 755 "$target"
}

compat_pkg_write_gentoo_postinst() {
	local target
	target="$1"
	cat >> "$target" <<- EOF
	pkg_postinst() {
	$(cat "$postinst")
	}
	EOF
}

compat_pkg_write_gentoo_prerm() {
	local target
	target="$1"
	cat >> "$target" <<- EOF
	pkg_prerm() {
	$(cat "$prerm")
	}
	EOF
}

# Keep compatibility with 2.10 and older

write_bin() {
	local application
	for application in "$@"; do
		launcher_write_script "$application"
	done
}

write_desktop() {
	local application
	for application in "$@"; do
		launcher_write_desktop "$application"
	done
}

write_desktop_winecfg() {
	launcher_write_desktop 'APP_WINECFG'
}

write_launcher() {
	launchers_write "$@"
}

# Keep compatibility with 2.7 and older

extract_and_sort_icons_from() {
	icons_get_from_package "$@"
}

extract_icon_from() {
	# Do nothing if the calling script explicitely asked for skipping icons extraction
	[ $SKIP_ICONS -eq 1 ] && return 0

	local destination
	local file
	destination="$PLAYIT_WORKDIR/icons"
	mkdir --parents "$destination"
	for file in "$@"; do
		extension="${file##*.}"
		case "$extension" in
			('exe')
				icon_extract_ico_from_exe "$file" "$destination"
			;;
			(*)
				icon_extract_png_from_file "$file" "$destination"
			;;
		esac
	done
}

get_icon_from_temp_dir() {
	icons_get_from_workdir "$@"
}

move_icons_to() {
	icons_move_to "$@"
}

postinst_icons_linking() {
	icons_linking_postinst "$@"
}

# Keep compatibility with 2.6.0 and older

set_archive() {
	archive_set "$@"
}

set_archive_error_not_found() {
	archive_set_error_not_found "$@"
}

