# prepare package layout by putting files from archive in the right packages
# directories
# USAGE: prepare_package_layout [$pkg…]
# NEEDED VARS: (LANG) PLAYIT_WORKDIR (PKG_PATH)
prepare_package_layout() {
	if [ -z "$1" ]; then
		# shellcheck disable=SC2046
		prepare_package_layout $(packages_get_list)
		return 0
	fi
	local package
	for package in "$@"; do
		PKG="$package"
		export PKG

		organize_data "GAME_${package#PKG_}" "$PATH_GAME"
		organize_data "DOC_${package#PKG_}"  "$PATH_DOC"
		for i in $(seq 0 9); do
			organize_data "GAME${i}_${package#PKG_}" "$PATH_GAME"
			organize_data "DOC${i}_${package#PKG_}"  "$PATH_DOC"
		done
	done
}

# put files from archive in the right package directories
# USAGE: organize_data $id $path
organize_data() {
	local pkg_path archive_path archive_files source_path destination_path source_files_pattern source_file destination_file

	# get the current package
	local package
	package=$(package_get_current)

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	# Check that the current package is part of the target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${packages_list##*$package*}" ]; then
		warning_skip_package 'organize_data' "$package"
		return 0
	fi

	# Get current package path, check that it is set
	pkg_path=$(get_value "${package}_PATH")
	if [ -z "$pkg_path" ]; then
		error_invalid_argument 'PKG' 'organize_data'
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

