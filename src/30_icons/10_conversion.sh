# update dependencies list with commands needed for icons extraction
# USAGE: icons_list_dependencies
# RETURNS: nothing
# SIDE EFFECT: export $ICONS_DEPS, a variable including a space-separated list of required commands to handle the icons of the current game
icons_list_dependencies() {
	# Do nothing if the calling script explicitely asked for skipping icons extraction
	if [ "$SKIP_ICONS" -eq 1 ]; then
		return 0
	fi

	# Get list of applications
	local applications_list
	applications_list=$(applications_list)

	# Return early if there is no application for the current game script
	if [ -z "$applications_list" ]; then
		return 0
	fi

	# Get list of icons
	local application application_icons_list full_icons_list
	for application in $applications_list; do
		application_icons_list=$(application_icons_list "$application")
		full_icons_list="$full_icons_list $application_icons_list"
	done

	# Get dependencies for each icon
	local icon
	for icon in $full_icons_list; do
		case "$icon" in
			('*.bmp'|'*.ico')
				ICONS_DEPS="$ICONS_DEPS identify convert"
			;;
			('*.exe')
				ICONS_DEPS="$ICONS_DEPS identify convert wrestool"
			;;
		esac
	done

	export ICONS_DEPS
}

# Fetch icon from the archive contents,
# convert it to PNG if it is not already in a supported format,
# include it in the current package.
#
# This function is the one that should be called from game scripts,
# it can take several applications as its arguments,
# and default to handle all applications if none are explicitely given.
#
# USAGE: icons_inclusion $application[…]
icons_inclusion() {
	# Do nothing if icons inclusion has been disabled
	if [ "$SKIP_ICONS" -eq 1 ]; then
		return 0
	fi

	# If no applications are explicitely listed,
	# try to fetch the icons for all applications.
	if [ "$#" -eq 0 ]; then
		applications_list=$(applications_list)
		# If icons_inclusion has been called with no argument,
		# the applications list should not be empty.
		if [ -z "$applications_list" ]; then
			error_applications_list_empty
			return 1
		fi
		icons_inclusion $applications_list
		return 0
	fi

	local application
	for application in "$@"; do
		assert_not_empty 'application' 'icons_inclusion'
		icons_inclusion_single_application "$application"
	done
}

# Fetch icon from the archive contents,
# convert it to PNG if it is not already in a supported format,
# include it in the current package.
#
# This function handles all icons for a given application.
#
# USAGE: icons_inclusion_single_application $application
icons_inclusion_single_application() {
	local application
	application="$1"
	assert_not_empty 'application' 'icons_inclusion_single_application'

	local application_icons_list
	application_icons_list=$(application_icons_list "$application")
	# Return early if the current application has no associated icon
	if [ -z "$application_icons_list" ]; then
		return 0
	fi

	local icon
	for icon in $application_icons_list; do
		icons_inclusion_single_icon "$application" "$icon"
	done
}

# Fetch icon from the archive contents,
# convert it to PNG if it is not already in a supported format,
# include it in the current package.
#
# This function handles a single icon.
#
# USAGE: icons_inclusion_single_icon $application $icon
icons_inclusion_single_icon() {
	local application
	application="$1"
	assert_not_empty 'application' 'icons_inclusion_single_icon'

	local icon
	icon="$2"
	assert_not_empty 'icon' 'icons_inclusion_single_icon'

	# Compute icon file full path
	local content_path icon_source_directory icon_path icon_full_path
	content_path=$(content_path_default)
	icon_source_directory="${PLAYIT_WORKDIR}/gamedata/${content_path}"
	icon_path=$(icon_path "$icon")
	icon_full_path="${icon_source_directory}/${icon_path}"

	# Check for icon file existence
	if [ ! -f "$icon_full_path" ]; then
		error_icon_file_not_found "$icon_full_path"
		return 1
	fi

	# TODO - wrestool options string should not be relying on a global variable
	if printf '%s' "$icon_path" | grep --quiet '\.exe$'; then
		WRESTOOL_OPTIONS=$(icon_wrestool_options "$icon")
		export WRESTOOL_OPTIONS
	fi

	icons_temporary_directory="${PLAYIT_WORKDIR}/icons"
	icon_extract_png_from_file "$icon_full_path" "$icons_temporary_directory"
	icons_include_from_directory "$application" "$icons_temporary_directory"

	# TODO - wrestool options string should not be relying on a global variable
	unset WRESTOOL_OPTIONS
}

# extract .png file(s) from target file
# USAGE: icon_extract_png_from_file $file $destination
# RETURNS: nothing
# SIDE EFFECT: convert the given file to .png icons, the .png files are created in the given directory
icon_extract_png_from_file() {
	local icon_file destination icon_type
	icon_file="$1"
	destination="$2"
	icon_type=$(file_type "$icon_file")
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
	# Get the application id
	local application application_id
	application="$1"
	application_id=$(application_id "$application")

	# Get the icons from the given source directory,
	# then move them to the current package
	local source_directory source_file destination_name destination_directory destination_file path_icons
	source_directory="$2"
	path_icons=$(path_icons)
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
		destination_directory="$(package_get_path "$(package_get_current)")${path_icons}/$(icon_get_resolution "$source_file")/apps"

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
	image_resolution_string=$(identify "$image_file" | sed "s;^${image_file} ;;" | cut --delimiter=' ' --fields=2)
	image_resolution="${image_resolution_string%+0+0}"

	printf '%s' "$image_resolution"
	return 0
}
