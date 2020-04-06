# prepare package layout by putting files from archive in the right packages
# directories
# USAGE: prepare_package_layout [$pkg…]
# NEEDED VARS: (LANG) (PACKAGES_LIST) PLAYIT_WORKDIR (PKG_PATH)
prepare_package_layout() {
	if [ -z "$1" ]; then
		[ -n "$PACKAGES_LIST" ] || prepare_package_layout_error_no_list
		prepare_package_layout $PACKAGES_LIST
		return 0
	fi
	for package in "$@"; do
		PKG="$package"
		organize_data "GAME_${PKG#PKG_}" "$PATH_GAME"
		organize_data "DOC_${PKG#PKG_}"  "$PATH_DOC"
		for i in $(seq 0 9); do
			organize_data "GAME${i}_${PKG#PKG_}" "$PATH_GAME"
			organize_data "DOC${i}_${PKG#PKG_}"  "$PATH_DOC"
		done
	done
}

# put files from archive in the right package directories
# USAGE: organize_data $id $path
organize_data() {
	local pkg_path archive_path archive_files source_path destination_path source_files_pattern source_file destination_file

	# This function requires PKG to be set
	if [ -z "$PKG" ]; then
		organize_data_error_missing_pkg
	fi

	# Check that the current package is part of the target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${PACKAGES_LIST##*$PKG*}" ]; then
		skipping_pkg_warning 'organize_data' "$PKG"
		return 0
	fi

	# Get current package path, check that it is set
	pkg_path=$(get_value "${PKG}_PATH")
	if [ -z "$pkg_path" ]; then
		missing_pkg_error 'organize_data' "$PKG"
	fi

	use_archive_specific_value "ARCHIVE_${1}_PATH"
	archive_path=$(get_value "ARCHIVE_${1}_PATH")
	use_archive_specific_value "ARCHIVE_${1}_FILES"
	archive_files=$(get_value "ARCHIVE_${1}_FILES")
	destination_path="${pkg_path}${2}"
	source_path="$PLAYIT_WORKDIR/gamedata/$archive_path"

	# When called in dry-run mode, return early
	if [ $DRY_RUN -eq 1 ]; then
		return 0
	fi

	if \
		[ -n "$archive_path" ] && \
		[ -n "$archive_files" ] && \
		[ -d "$source_path" ]
	then
		mkdir --parents "$destination_path"
		set -o noglob
		for source_files_pattern in $archive_files; do
			set +o noglob
			for source_file in "$source_path"/$source_files_pattern; do
				if [ -e "$source_file" ]; then
					destination_file="${destination_path}/${source_file#$source_path}"
					mkdir --parents "$(dirname "$destination_file")"
					cp \
						--recursive \
						--force \
						--link \
						--no-dereference \
						--no-target-directory \
						--preserve=links \
						"$source_file" "$destination_file"
					rm --force --recursive "$source_file"
				fi
			done
			set -o noglob
		done
		set +o noglob
	fi
}

