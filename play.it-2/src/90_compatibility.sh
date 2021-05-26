# Keep compatibility with 2.13 and older

icon_get_resolution_from_file() {
	resolution=$(icon_get_resolution "$@")
	export resolution
}

# Keep compatibility with 2.12 and older

archives_get_list() {
	ARCHIVES_LIST=$(archives_return_list)
	export ARCHIVES_LIST
}

get_package_version() {
	PKG_VERSION=$(packages_get_version "$ARCHIVE")
	export PKG_VERSION
}

set_architecture() {
	pkg_architecture=$(package_get_architecture_string "$1")
	export pkg_architecture
}

icons_linking_postinst() {
	if \
		! version_is_at_least '2.8' "$target_version" && \
		[ -z "${PACKAGES_LIST##*PKG_DATA*}" ]
	then
		(
			PKG='PKG_DATA'
			icons_get_from_package "$@"
		)
	else
		icons_get_from_package "$@"
	fi
}

archive_set() {
	archive_initialize_optional "$@"
	# shellcheck disable=SC2039
	local archive
	archive=$(archive_find_from_candidates "$@")
	if [ -n "$archive" ]; then
		ARCHIVE="$archive"
		export ARCHIVE
	fi
}

version_target_is_older_than() {
	if [ "$1" = "${VERSION_MAJOR_TARGET}.${VERSION_MINOR_TARGET}" ]; then
		return 1
	fi
	version_is_at_least "${VERSION_MAJOR_TARGET}.${VERSION_MINOR_TARGET}" "$1"
}

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

liberror() {
	error_invalid_argument "$1" "$2"
}

skipping_pkg_warning() {
	warning_skip_package "$1" "$2"
}

archive_set_error_not_found() {
	error_archive_not_found "$@"
}

archive_guess_type_error() {
	error_archive_type_not_set "$1"
}

archive_print_file_in_use() {
	information_file_in_use "$1"
}

archive_integrity_check_error() {
	error_hashsum_mismatch "$1"
}

select_package_architecture_warning_unavailable() {
	warning_architecture_not_available "$OPTION_ARCHITECTURE"
}

select_package_architecture_error_unknown() {
	error_architecture_not_supported "$OPTION_ARCHITECTURE"
}

select_package_architecture_warning_unsupported() {
	warning_option_not_supported '--architecture'
}

error_no_pkg() {
	error_variable_not_set "$1" '$PKG'
}

set_temp_directories_error_no_size() {
	error_variable_not_set 'set_temp_directories' '$ARCHIVE_SIZE'
}

prepare_package_layout_error_no_list() {
	error_variable_not_set 'prepare_package_layout' '$PACKAGES_LIST'
}

organize_data_error_missing_pkg() {
	error_variable_not_set 'organize_data' '$PKG'
}

icon_path_empty_error() {
	error_variable_not_set 'icons_get_from_path' '$'"$1"
}

set_temp_directories_error_not_enough_space() {
	# shellcheck disable=SC2046
	error_not_enough_free_space $(temporary_directories_list_candidates)
}

archive_extraction_innosetup_error_version() {
	error_innoextract_version_too_old "$1"
}

icon_file_not_found_error() {
	error_icon_file_not_found "$1"
}

missing_pkg_error() {
	error_invalid_argument 'PKG' "$1"
}

pkg_build_print_already_exists() {
	information_package_already_exists "$1"
}

archive_integrity_check_print() {
	information_file_integrity_check "$1"
}

extract_data_from_print() {
	information_archive_data_extraction "$1"
}

pkg_print() {
	information_package_building "$1"
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

# Keep compatibility with 2.8 and older

icon_get_resolution_pre_2_8() {
	# shellcheck disable=SC2039
	local image_file image_resolution_string image_resolution string_field
	image_file="$1"
	string_field=2
	while
		[ -z "$image_resolution" ] || \
		[ -n "$(printf '%s' "$image_resolution" | sed 's/[0-9]*x[0-9]*//')" ]
	do
		if [ -n "${file##* *}" ]; then
			image_resolution_string=$(identify $image_file | cut --delimiter=' ' --fields=$string_field)
		else
			image_resolution_string=$(identify "$image_file" | cut --delimiter=' ' --fields=$string_field)
		fi
		image_resolution="${image_resolution_string%+0+0}"
		string_field=$((string_field + 1))
	done

	printf '%s' "$image_resolution"
	return 0
}

icon_check_file_existence_pre_2_8() {
	# shellcheck disable=SC2039
	local directory file
	directory="$1"
	file="$2"

	if \
		[ -z "${file##* *}" ] || \
		[ ! -f "$directory"/$file ]
	then
		error_icon_file_not_found "$directory/$file"
		return 1
	else
		# get the real file name from its globbed one
		# shellcheck disable=SC2039
		local file_path
		file_path=$(eval printf '%s' "$directory/$file")
		file="${file_path#${directory}/}"
	fi

	printf '%s' "$file"
	return 0
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

