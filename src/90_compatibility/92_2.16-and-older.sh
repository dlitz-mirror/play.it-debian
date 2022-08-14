# Keep compatibility with 2.16 and older

icons_get_from_package() {
	local package package_path
	package=$(package_get_current)
	package_path=$(package_get_path "$package")
	icon_source_directory="${package_path}/${PATH_GAME}"
	icons_get_from_legacy_path "$icon_source_directory" "$@"
}

icons_get_from_workdir() {
	local icon_source_directory
	icon_source_directory="${PLAYIT_WORKDIR}/gamedata"
	icons_get_from_legacy_path "$icon_source_directory" "$@"
}

icons_get_from_legacy_path() {
	local icon_source_directory_legacy
	icon_source_directory_legacy="$1"
	shift 1
	if [ -z "$CONTENT_PATH_DEFAULT" ]; then
		local CONTENT_PATH_DEFAULT
		CONTENT_PATH_DEFAULT='.'
	fi
	local application
	for application in "$@"; do
		assert_not_empty 'application' 'icons_get_from_path'
		local application_icons_list
		application_icons_list=$(application_icons_list "$application")
		if [ -z "$application_icons_list" ]; then
			continue
		fi
		local icon
		for icon in $application_icons_list; do
			assert_not_empty 'icon' 'icons_get_from_path'
			local icon_path icon_full_path_legacy content_path icon_source_directory_new icon_full_path_new
			icon_path=$(icon_path "$icon")
			# Compute icon legacy path
			icon_full_path_legacy="${icon_source_directory_legacy}/${icon_path}"
			# Compute icon expected path for new function
			content_path=$(content_path_default)
			icon_source_directory_new="${PLAYIT_WORKDIR}/gamedata/${content_path}"
			icon_full_path_new="${icon_source_directory_new}/${icon_path}"
			# Set compatibility link
			icon_full_path_legacy_canonical=$(realpath --canonicalize-missing "$icon_full_path_legacy")
			icon_full_path_new_canonical=$(realpath --canonicalize-missing "$icon_full_path_new")
			if [ "$icon_full_path_legacy_canonical" != "$icon_full_path_new_canonical" ]; then
				mkdir --parents "$(dirname "$icon_full_path_new")"
				ln --symbolic "$icon_full_path_legacy" "$icon_full_path_new"
			fi
			# Call new function
			icons_inclusion_single_icon "$application" "$icon"
			# Remove compatibility link
			if [ "$icon_full_path_legacy_canonical" != "$icon_full_path_new_canonical" ]; then
				rm "$icon_full_path_new"
				# Do not try to delete "…/gamedata/.", rmdir would fail with "Invalid argument"
				if [ "$CONTENT_PATH_DEFAULT" != '.' ]; then
					rmdir --parents --ignore-fail-on-non-empty "$(dirname "$icon_full_path_new")"
				fi
			fi
		done
	done
}

icons_move_to() {
	if [ "$SKIP_ICONS" -eq 1 ]; then
		return 0
	fi

	local source_package source_directory destination_package destination_directory
	source_package=$(package_get_current)
	source_directory="$(package_get_path "$source_package")${PATH_ICON_BASE}"
	destination_package="$1"
	destination_directory="$(package_get_path "$destination_package")${PATH_ICON_BASE}"

	# a basic `mv` call here would fail if the destination is not empty
	mkdir --parents "$destination_directory"
	cp --link --recursive "$source_directory"/* "$destination_directory"
	rm --recursive "${source_directory:?}"/*
	rmdir --ignore-fail-on-non-empty --parents "$source_directory"
}
