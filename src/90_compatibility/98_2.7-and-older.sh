# Keep compatibility with 2.7 and older

icon_get_resolution_pre_2_8() {
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
		local file_path
		file_path=$(eval printf '%s' "$directory/$file")
		file=${file_path#"${directory}/"}
	fi

	printf '%s' "$file"
	return 0
}

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

