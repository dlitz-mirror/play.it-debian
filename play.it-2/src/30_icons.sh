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
	local app
	local destination
	local directory
	local file
	local icon
	local list
	local wrestool_id

	# get the current package
	local package
	package=$(package_get_current)

	directory="$1"
	shift 1
	destination="$PLAYIT_WORKDIR/icons"
	for app in "$@"; do
		if ! testvar "$app" 'APP'; then
			error_invalid_argument 'app' 'icons_get_from_package'
		fi
		list="$(get_value "${app}_ICONS_LIST")"
		[ -n "$list" ] || list="${app}_ICON"
		for icon in $list; do
			use_archive_specific_value "$icon"
			file="$(get_value "$icon")"
			if [ -z "$file" ]; then
				error_variable_not_set 'icons_get_from_path' '$'"$icon"
			fi

			# Check icon file existence
			file=$(icon_check_file_existence "$directory" "$file")

			wrestool_id="$(get_value "${icon}_ID")"
			icon_extract_png_from_file "$directory/$file" "$destination"
			icons_include_png_from_directory "$app" "$destination"
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
		if version_target_is_older_than '2.8'; then
			file=$(icon_check_file_existence_pre_2_8 "$directory" "$file")
		else
			error_icon_file_not_found "$directory/$file"
		fi
	fi

	printf '%s' "$file"
	return 0
}

# extract .png file(s) from target file
# USAGE: icon_extract_png_from_file $file $destination
# RETURNS: nothing
# SIDE EFFECT: convert the given file to .png icons, the .png files are created in the given directory
icon_extract_png_from_file() {
	local destination
	local extension
	local file
	file="$1"
	destination="$2"
	extension="${file##*.}"
	mkdir --parents "$destination"
	case "$extension" in
		('bmp')
			icon_convert_bmp_to_png "$file" "$destination"
		;;
		('exe')
			icon_extract_png_from_exe "$file" "$destination"
		;;
		('ico')
			icon_extract_png_from_ico "$file" "$destination"
		;;
		('png')
			icon_copy_png "$file" "$destination"
		;;
		(*)
			error_invalid_argument 'extension' 'icon_extract_png_from_file'
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

# extract .ico file(s) from .exe
# USAGE: icon_extract_ico_from_exe $file $destination
# RETURNS: nothing
# SIDE EFFECT: extract .ico icons from the given .exe file, the .ico files are created in the given directory
icon_extract_ico_from_exe() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	local destination
	local file
	local options
	file="$1"
	destination="$2"
	[ "$wrestool_id" ] && options="--name=$wrestool_id"
	debug_external_command "wrestool --extract --type=14 $options --output=\"$destination\" \"$file\" 2>/dev/null"
	wrestool --extract --type=14 $options --output="$destination" "$file" 2>/dev/null
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

# get .png file(s) from target directory and put them in current package
# USAGE: icons_include_png_from_directory $app $directory
# RETURNS: nothing
# SIDE EFFECT: take the icons from the given directory, move them to standard paths into the current package
icons_include_png_from_directory() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	local app
	local directory
	local file
	local path
	local path_icon
	local resolution

	# get the current package
	local package
	package=$(package_get_current)

	app="$1"
	directory="$2"
	name="$(get_value "${app}_ID")"
	[ -n "$name" ] || name="$GAME_ID"
	for file in "$directory"/*.png; do
		icon_get_resolution_from_file "$file"
		path_icon="$PATH_ICON_BASE/$resolution/apps"
		path="$(package_get_path "$package")${path_icon}"
		mkdir --parents "$path"
		mv "$file" "$path/$name.png"
	done
}
# compatibility alias
###
# TODO
# This function should be moved to the compatibility aliases source file
###
sort_icons() {
	local app
	local directory
	directory="$PLAYIT_WORKDIR/icons"
	for app in "$@"; do
		icons_include_png_from_directory "$app" "$directory"
	done
}

# get image resolution for target file, exported as $resolution
# USAGE: icon_get_resolution_from_file $file
# RETURNS: nothing
# SIDE EFFECT: export the resolution of the given file as $resolution, using the format "${width}x${height}"
icon_get_resolution_from_file() {
	local file
	file="$1"

	# `identify` should be available when this function is called.
	# Exits with an explicit error if it is missing
	if ! command -v 'identify' >/dev/null 2>&1; then
		error_unavailable_command 'icon_get_resolution_from_file' 'identify'
	fi

	if ! version_is_at_least '2.8' "$target_version" && [ -n "${file##* *}" ]; then
		field=2
		unset resolution
		while
			[ -z "$resolution" ] || \
			[ -n "$(printf '%s' "$resolution" | sed 's/[0-9]*x[0-9]*//')" ]
		do
			resolution="$(identify $file | sed "s;^$file ;;" | cut --delimiter=' ' --fields=$field)"
			resolution="${resolution%+0+0}"
			field=$((field + 1))
		done
	else
		resolution="$(identify "$file" | sed "s;^$file ;;" | cut --delimiter=' ' --fields=2)"
		resolution="${resolution%+0+0}"
	fi
	export resolution
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

