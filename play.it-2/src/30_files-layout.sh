# prepare package layout by putting files from archive in the right packages
# directories
# USAGE: prepare_package_layout [$pkg…]
# NEEDED VARS: (LANG) PLAYIT_WORKDIR
prepare_package_layout() {
	if [ -z "$1" ]; then
		# shellcheck disable=SC2046
		prepare_package_layout $(packages_get_list)
		return 0
	fi

	debug_entering_function 'prepare_package_layout'

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

	debug_leaving_function 'prepare_package_layout'
}

# put files from archive in the right package directories
# USAGE: organize_data $content_id $target_path
organize_data() {
	local content_id target_path
	content_id="$1"
	target_path="$2"

	# Get list of files, and path to files
	local archive_files archive_path
	archive_files=$(get_context_specific_value 'archive'  "ARCHIVE_${content_id}_FILES")
	if [ -z "$archive_files" ]; then
		# No list of files for current content, skipping
		return 0
	fi
	archive_path=$(get_context_specific_value 'archive' "ARCHIVE_${content_id}_PATH")
	if [ -z "$archive_path" ]; then
		archive_path=$(content_path_default)
	fi

	# Set path to source and destination
	local package package_path destination_path source_path
	source_path="$PLAYIT_WORKDIR/gamedata/$archive_path"
	package=$(package_get_current)
	package_path=$(package_get_path "$package")
	destination_path="${package_path}${target_path}"

	# When called in dry-run mode, return early
	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	# Proceed with the actual files inclusion
	local source_files_pattern source_file destination_file
	if [ -d "$source_path" ]; then
		mkdir --parents "$destination_path"
		set -o noglob
		for source_files_pattern in $archive_files; do
			set +o noglob
			for source_file in "$source_path"/$source_files_pattern; do
				if [ -e "$source_file" ]; then
					debug_source_file 'Found' "${archive_path}${source_file#"$source_path"}"
					destination_file="${destination_path}/${source_file#"$source_path"}"
					debug_file_to_package "$package"
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
				else
					debug_source_file 'Missing' "${archive_path}${source_file#"$source_path"}"
				fi
			done
			set -o noglob
		done
		set +o noglob
	fi
}

