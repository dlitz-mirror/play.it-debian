# update dependencies list with commands needed for icons extraction
# USAGE: icons_list_dependencies
# RETURNS: nothing
# SIDE EFFECT: export $ICONS_DEPS, a variable including a space-separated list of required commands to handle the icons of the current game
icons_list_dependencies() {
	# Do nothing if the calling script explicitely asked for skipping icons extraction
	[ $SKIP_ICONS -eq 1 ] && return 0

	local script
	script="$0"
	if grep \
		--quiet \
		--regexp="^APP_[^_]\\+_ICON='.\\+'" \
		--regexp="^APP_[^_]\\+_ICON_.\\+='.\\+'" \
		"$script"
	then
		ICONS_DEPS="$ICONS_DEPS identify"
		if grep \
			--quiet \
			--regexp="^APP_[^_]\\+_ICON='.\\+\\.bmp'" \
			--regexp="^APP_[^_]\\+_ICON_.\\+='.\\+\\.bmp'" \
			--regexp="^APP_[^_]\\+_ICON='.\\+\\.ico'" \
			--regexp="^APP_[^_]\\+_ICON_.\\+='.\\+\\.ico'" \
			"$script"
		then
			ICONS_DEPS="$ICONS_DEPS convert"
		fi
		if grep \
			--quiet \
			--regexp="^APP_[^_]\\+_ICON='.\\+\\.exe'" \
			--regexp="^APP_[^_]\\+_ICON_.\\+='.\\+\\.exe'" \
			"$script"
		then
			ICONS_DEPS="$ICONS_DEPS convert wrestool"
		fi
	fi
	export ICONS_DEPS
}

# get .png file(s) from various icon sources in current package
# USAGE: icons_get_from_package $app[…]
# RETURNS: nothing
# SIDE EFFECT: get original icon files from the current package,
#              convert them to standard icon formats,
#              and include the standard icons in the current package
icons_get_from_package() {
	# Do nothing if the calling script explicitely asked for skipping icons extraction
	[ $SKIP_ICONS -eq 1 ] && return 0

	# get the current package
	local package
	package=$(package_get_current)

	local path
	path="$(package_get_path "$package")${PATH_GAME}"
	icons_get_from_path "$path" "$@"
}

# get .png file(s) from various icon sources in temporary work directory
# USAGE: icons_get_from_workdir $app[…]
# RETURNS: nothing
# SIDE EFFECT: get original icon files from ./play.it temporary directory,
#              convert them to standard icon formats,
#              and include the standard icons in the current package
icons_get_from_workdir() {
	# Do nothing if the calling script explicitely asked for skipping icons extraction
	[ $SKIP_ICONS -eq 1 ] && return 0

	local path
	path="$PLAYIT_WORKDIR/gamedata"
	icons_get_from_path "$path" "$@"
}

# get .png file(s) from various icon sources
# USAGE: icons_get_from_path $directory $app[…]
# RETURNS: nothing
# SIDE EFFECT: get original icon files from the given directory,
#              convert them to standard icon formats,
#              and include the standard icons in the current package
icons_get_from_path() {
	local destination directory
	destination="$PLAYIT_WORKDIR/icons"
	directory="$1"
	shift 1

	local application application_icons_list icon icon_path
	for application in "$@"; do
		application_icons_list=$(application_icons_list "$application")
		for icon in $application_icons_list; do
			# Check icon file existence
			icon_path=$(icon_check_file_existence "$directory" "$(icon_path "$icon")")

			###
			# TODO
			# wrestool options string is passed as a global variable,
			# there is probably a better way to handle that.
			###
			if icon_path "$icon" | grep --quiet '\.exe$'; then
				WRESTOOL_OPTIONS=$(icon_wrestool_options "$icon")
				export WRESTOOL_OPTIONS
			fi

			icon_extract_png_from_file "$directory/$icon_path" "$destination"
			icons_include_png_from_directory "$application" "$destination"

			unset WRESTOOL_OPTIONS
		done
	done
}

# check icon file existence
# USAGE: icon_check_file_existence $directory $file
# RETURNS: $file or throws an error
icon_check_file_existence() {
	local directory file
	directory="$1"
	file="$2"

	# Return early in dry-run mode
	if [ $DRY_RUN -eq 1 ]; then
		printf '%s' "$file"
		return 0
	fi

	if [ ! -f "$directory/$file" ]; then
		# pre-2.8 scripts could use globbing in file path
		# shellcheck disable=SC2154
		if version_is_at_least '2.8' "$target_version"; then
			error_icon_file_not_found "$directory/$file"
			return 1
		else
			file=$(icon_check_file_existence_pre_2_8 "$directory" "$file")
		fi
	fi

	printf '%s' "$file"
	return 0
}

# Return the MIME type of a given icon file
# USAGE: icon_file_type $icon_file
# RETURNS: the MIME type, as a string
icon_file_type() {
	file --brief --mime-type "$1"
}

# extract .png file(s) from target file
# USAGE: icon_extract_png_from_file $file $destination
# RETURNS: nothing
# SIDE EFFECT: convert the given file to .png icons, the .png files are created in the given directory
icon_extract_png_from_file() {
	local icon_file destination icon_type
	icon_file="$1"
	destination="$2"
	icon_type=$(icon_file_type "$icon_file")
	mkdir --parents "$destination"
	case "$icon_type" in
		('application/x-dosexec')
			icon_extract_png_from_exe "$icon_file" "$destination"
		;;
		('image/png')
			icon_copy_png "$icon_file" "$destination"
		;;
		('image/vnd.microsoft.icon')
			icon_extract_png_from_ico "$icon_file" "$destination"
		;;
		('image/bmp'|'image/x-ms-bmp')
			icon_convert_bmp_to_png "$icon_file" "$destination"
		;;
		('image/x-xpmi')
			icon_copy_xpm "$icon_file" "$destination"
		;;
		(*)
			error_icon_unsupported_type "$icon_file" "$icon_type"
			return 1
		;;
	esac
}

# extract .png file(s) for .exe
# USAGE: icon_extract_png_from_exe $file $destination
# RETURNS: nothing
# SIDE EFFECT: extract .png icons from the given .exe file, the .png files are created in the given directory
icon_extract_png_from_exe() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	local destination
	local file
	file="$1"
	destination="$2"
	icon_extract_ico_from_exe "$file" "$destination"
	for file in "$destination"/*.ico; do
		icon_extract_png_from_ico "$file" "$destination"
		rm "$file"
	done
}

# extract .ico file(s) from given .exe file
# USAGE: icon_extract_ico_from_exe $icon_file $destination
icon_extract_ico_from_exe() {
	local destination icon_file
	icon_file="$1"
	destination="$2"

	###
	# TODO
	# This function relies on a globally set WRESTOOL_OPTIONS variable,
	# there is probably a better way to handle that.
	###

	debug_external_command "wrestool $WRESTOOL_OPTIONS --extract --output=\"$destination\" \"$icon_file\" 2>/dev/null"

	# Return early if run in dry-run mode
	[ "$DRY_RUN" -eq 1 ] && return 0

	# shellcheck disable=SC2086
	wrestool $WRESTOOL_OPTIONS --extract --output="$destination" "$icon_file" 2>/dev/null
}

# convert .bmp file to .png
# USAGE: icon_convert_bmp_to_png $file $destination
# RETURNS: nothing
# SIDE EFFECT: convert the given .bmp file to .png, the .png file is created in the given directory
icon_convert_bmp_to_png() { icon_convert_to_png "$@"; }

# extract .png file(s) from .ico
# USAGE: icon_extract_png_from_ico $file $destination
# RETURNS: nothing
# SIDE EFFECT: convert the given .ico file to .png, the .png files are created in the given directory
icon_extract_png_from_ico() { icon_convert_to_png "$@"; }

# convert multiple icon formats to .png
# USAGE: icon_convert_to_png $file $destination
# RETURNS: nothing
# SIDE EFFECT: convert the given image file to .png, the .png files are created in the given directory
icon_convert_to_png() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	local destination
	local file
	local name
	file="$1"
	destination="$2"
	name="$(basename "$file")"
	debug_external_command "convert \"$file\" \"$destination/${name%.*}.png\""
	convert "$file" "$destination/${name%.*}.png"
}

# copy .png file to directory
# USAGE: icon_copy_png $file $destination
# RETURNS: nothing
# SIDE EFFECT: copy the given .png file to the given directory
icon_copy_png() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	local destination
	local file
	file="$1"
	destination="$2"
	cp "$file" "$destination"
}

# copy .xpm file to directory
# USAGE: icon_copy_xpm $file $destination
# RETURNS: nothing
# SIDE EFFECT: copy the given .png file to the given directory
icon_copy_xpm() {
	# Return early if called in dry-run mode
	if [ $DRY_RUN -eq 1 ]; then
		return 0
	fi

	local destination file
	file="$1"
	destination="$2"
	cp "$file" "$destination"

	return 0
}

# Get icon files from the given directory and put them in the current package
# USAGE: icons_include_from_directory $app $directory
# RETURNS: nothing
# SIDE EFFECT: take the icons from the given directory, move them to standard paths into the current package
icons_include_from_directory() {
	# Return early if called in dry-run mode
	if [ $DRY_RUN -eq 1 ]; then
		return 0
	fi

	# Get the application id
	local application application_id
	application="$1"
	application_id=$(application_id "$application")

	# Get the icons from the given source directory,
	# then move them to the current package
	local source_directory source_file destination_name destination_directory destination_file
	source_directory="$2"
	for source_file in \
		"$source_directory"/*.png \
		"$source_directory"/*.xpm
	do
		# Skip the current pattern if it matched no file
		if [ ! -e "$source_file" ]; then
			continue
		fi

		# Compute icon file name
		destination_name="${application_id}.${source_file##*.}"

		# Compute icon path
		destination_directory="$(package_get_path "$(package_get_current)")${PATH_ICON_BASE}/$(icon_get_resolution "$source_file")/apps"

		# Move current icon file to its destination
		destination_file="${destination_directory}/${destination_name}"
		mkdir --parents "$destination_directory"
		mv "$source_file" "$destination_file"
	done
}

# Return the resolution of the given image file
# USAGE: icon_get_resolution $file
# RETURNS: image resolution, using the format ${width}x${height}
icon_get_resolution() {
	local image_file
	image_file="$1"

	# `identify` should be available when this function is called.
	# Exits with an explicit error if it is missing
	if ! command -v 'identify' >/dev/null 2>&1; then
		error_unavailable_command 'icon_get_resolution' 'identify'
		return 1
	fi

	local image_resolution_string image_resolution
	# shellcheck disable=SC2154
	if version_is_at_least '2.8' "$target_version"; then
		image_resolution_string=$(identify "$image_file" | sed "s;^${image_file} ;;" | cut --delimiter=' ' --fields=2)
		image_resolution="${image_resolution_string%+0+0}"
	else
		image_resolution=$(icon_get_resolution_pre_2_8 "$image_file")
	fi

	printf '%s' "$image_resolution"
	return 0
}

# move icons to the target package
# USAGE: icons_move_to $pkg
# RETURNS: nothing
# SIDE EFFECT: move the icons from the current package to the given package
icons_move_to() {
	###
	# TODO
	# Check that $destination_package is set to a valid package
	# Check that $PATH_ICON_BASE is set to an absolute path
	###

	# Do nothing if the calling script explicitely asked for skipping icons extraction
	[ $SKIP_ICONS -eq 1 ] && return 0

	local source_package      source_path      source_directory
	local destination_package destination_path destination_directory
	source_package=$(package_get_current)
	source_directory="$(package_get_path "$source_package")${PATH_ICON_BASE}"
	destination_package="$1"
	destination_directory="$(package_get_path "$destination_package")${PATH_ICON_BASE}"

	# If called in dry-run mode, return early
	if [ $DRY_RUN -eq 1 ]; then
		return 0
	fi

	# a basic `mv` call here would fail if the destination is not empty
	mkdir --parents "$destination_directory"
	cp --link --recursive "$source_directory"/* "$destination_directory"
	rm --recursive "${source_directory:?}"/*
	rmdir --ignore-fail-on-non-empty --parents "$source_directory"
}

