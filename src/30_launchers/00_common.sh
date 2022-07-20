# write launcher script
# USAGE: launcher_write_script $app
launcher_write_script() {
	# parse argument
	local application
	application="$1"
	if ! testvar "$application" 'APP'; then
		error_invalid_argument 'application' 'launcher_write_script'
		return 1
	fi

	# compute file path
	local package package_path application_id target_file
	package=$(package_get_current)
	package_path=$(package_get_path "$package")
	application_id=$(application_id "$application")
	target_file="${package_path}${PATH_BIN}/${application_id}"

	# Get application type and prefix type
	local application_type prefix_type
	application_type=$(application_type "$application")
	prefix_type=$(application_prefix_type "$application")

	# Check that the launcher target exists
	local binary_path binary_found tested_package
	case "$application_type" in
		('residualvm'|'scummvm'|'renpy')
			# ResidualVM, ScummVM and Ren'Py games do not rely on a provided binary
		;;
		('mono')
			# Game binary for Mono games may be included in another package than the binaries one
			local packages_list
			packages_list=$(packages_get_list)
			binary_found=0
			for tested_package in $packages_list; do
				binary_path="$(package_get_path "$tested_package")${PATH_GAME}/$(application_exe "$application")"
				if [ -f "$binary_path" ]; then
					binary_found=1
					break;
				fi
			done
			if [ $binary_found -eq 0 ]; then
				binary_path="$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
				error_launcher_missing_binary "$binary_path"
				return 1
			fi
		;;
		('wine')
			if [ "$(application_exe "$application")" != 'winecfg' ]; then
				binary_path="$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
				if [ ! -f "$binary_path" ]; then
					error_launcher_missing_binary "$binary_path"
					return 1
				fi
			fi
		;;
		(*)
			binary_path="$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
			if [ ! -f "$binary_path" ]; then
				error_launcher_missing_binary "$binary_path"
				return 1
			fi
		;;
	esac

	# write launcher script
	debug_write_launcher "$application_type" "$binary_file"
	mkdir --parents "$(dirname "$target_file")"
	touch "$target_file"
	chmod 755 "$target_file"
	launcher_write_script_headers "$target_file"
	case "$application_type" in
		('dosbox')
			launcher_write_script_dosbox_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_print_persistent_paths >> "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			dosbox_prefix_function_toupper >> "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_dosbox_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('java')
			launcher_write_script_java_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_print_persistent_paths >> "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_java_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('native')
			case "$prefix_type" in
				('symlinks')
					launcher_write_script_native_application_variables "$application" "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_print_persistent_paths >> "$target_file"
					launcher_write_script_prefix_functions "$target_file"
					launcher_write_script_prefix_build "$target_file"
					launcher_write_script_native_run "$application" "$target_file"
					launcher_write_script_prefix_cleanup "$target_file"
				;;
				('none')
					launcher_write_script_native_application_variables "$application" "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_write_script_nativenoprefix_run "$application" "$target_file"
				;;
				('copy')
					# TODO
				;;
			esac
		;;
		('native_no-prefix')
			# WARNING - This archive type is deprecated.
			(
				export ${application}_TYPE='native'
				export ${application}_PREFIX_TYPE='none'
				launcher_write_script "$@"
			)
		;;
		('scummvm')
			launcher_write_script_scummvm_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_scummvm_run "$application" "$target_file"
		;;
		('renpy')
			launcher_write_script_game_variables "$target_file"
			launcher_print_persistent_paths >> "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_renpy_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('residualvm')
			launcher_write_script_residualvm_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_residualvm_run "$application" "$target_file"
		;;
		('unity3d')
			launcher_write_script_native_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_print_persistent_paths >> "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_unity3d_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('wine')
			if [ "$(application_id "$application")" != "$(game_id)_winecfg" ]; then
				launcher_write_script_wine_application_variables "$application" "$target_file"
			fi
			launcher_write_script_game_variables "$target_file"
			launcher_print_persistent_paths >> "$target_file"
			launcher_wine_command_path >> "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_wine_prefix_build "$target_file"
			if [ "$(application_id "$application")" = "$(game_id)_winecfg" ]; then
				launcher_write_script_winecfg_run "$target_file"
			else
				launcher_write_script_wine_run "$application" "$target_file"
			fi
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('mono')
			launcher_write_script_mono_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_print_persistent_paths >> "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_mono_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
	esac
	cat >> "$target_file" <<- 'EOF'
	exit 0
	EOF

	# for native applications, add execution permissions to the game binary file
	case "$application_type" in
		('native'|'unity3d')
			local binary_file
			binary_file="$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
			chmod +x "$binary_file"
		;;
	esac

	# for WINE applications, write launcher script for winecfg
	case "$application_type" in
		('wine')
			local winecfg_file
			winecfg_file="$(package_get_path "$package")${PATH_BIN}/$(game_id)_winecfg"
			if [ ! -e "$winecfg_file" ]; then
				launcher_write_script_wine_winecfg "$application"
			fi
		;;
	esac

	return 0
}

# write launcher script headers
# USAGE: launcher_write_script_headers $file
# NEEDED VARS: LIBRARY_VERSION
# CALLED BY: launcher_write_script
launcher_write_script_headers() {
	local file
	file="$1"
	cat > "$file" <<- EOF
	#!/bin/sh
	# script generated by ./play.it $LIBRARY_VERSION - https://www.dotslashplay.it/
	set -o errexit

	EOF
	return 0
}

# write launcher script game-specific variables
# USAGE: launcher_write_script_game_variables $file
launcher_write_script_game_variables() {
	local file
	file="$1"
	cat >> "$file" <<- EOF
	# Set game-specific values

	GAME_ID='$(game_id)'
	PATH_GAME='$PATH_GAME'

	EOF
	return 0
}

# write launcher script pre-run actions
# USAGE: launcher_write_script_prerun $application $file
launcher_write_script_prerun() {
	local application file
	application="$1"
	file="$2"

	# Return early if there are no pre-run actions for the given application
	if [ -z "$(application_prerun "$application")" ]; then
		return 0
	fi

	cat >> "$file" <<- EOF
	$(application_prerun "$application")

	EOF
}

# write launcher script post-run actions
# USAGE: launcher_write_script_postrun $application $file
launcher_write_script_postrun() {
	local application file
	application="$1"
	file="$2"

	# Return early if there are no post-run actions for the given application
	if [ -z "$(application_postrun "$application")" ]; then
		return 0
	fi

	cat >> "$file" <<- EOF
	$(application_postrun "$application")

	EOF
}

# write the XDG desktop file for the given application
# USAGE: launcher_write_desktop $application
launcher_write_desktop() {
	local application
	application="$1"

	# write desktop file
	local desktop_file
	desktop_file=$(launcher_desktop_filepath "$application")
	mkdir --parents "$(dirname "$desktop_file")"
	launcher_desktop "$application" > "$desktop_file"

	# WINE - Write XDG desktop file for winecfg
	local application_type
	application_type=$(application_type "$application" 'unknown')
	if \
		[ "$application_type" = 'wine' ] && \
		[ "$application" != 'APP_WINECFG' ]
	then
		local package package_path winecfg_desktop
		package=$(package_get_current)
		package_path=$(package_get_path "$package")
		game_id=$(game_id)
		winecfg_desktop="${package_path}${PATH_DESK}/${game_id}_winecfg.desktop"
		if [ ! -e "$winecfg_desktop" ]; then
			APP_WINECFG_ID="$(game_id)_winecfg"
			APP_WINECFG_NAME="$(game_name) - WINE configuration"
			APP_WINECFG_CAT='Settings'
			export APP_WINECFG_ID APP_WINECFG_NAME APP_WINECFG_CAT
			launcher_write_desktop 'APP_WINECFG'
		fi
	fi

	return 0
}

# print the content of the XDG desktop file for the given application
# USAGE: launcher_desktop $application
# RETURN: the full content of the XDG desktop file
launcher_desktop() {
	local application
	application="$1"

	###
	# TODO
	# This should be moved to a dedicated function,
	# probably in a 20_icons.sh source file
	###
	# get icon name
	local application_icon
	if [ "$application" = 'APP_WINECFG' ]; then
		application_icon='winecfg'
	else
		application_icon=$(application_id "$application")
	fi

	cat <<- EOF
	[Desktop Entry]
	Version=1.0
	Type=Application
	Name=$(application_name "$application")
	Icon=$application_icon
	$(launcher_desktop_exec "$application")
	Categories=$(application_category "$application")
	EOF
}

# print the full path to the XDG desktop file for the given application
# USAGE: launcher_desktop_filepath $application
# RETURN: an absolute file path
launcher_desktop_filepath() {
	local application application_id package package_path
	application="$1"
	application_id=$(application_id "$application")
	package=$(package_get_current)
	package_path=$(package_get_path "$package")

	printf '%s/%s.desktop' \
		"${package_path}${PATH_DESK}" \
		"$application_id"
}

# print the XDG desktop "Exec" field for the given application
# USAGE: launcher_desktop_exec $application
# RETURN: the "Exec" field string, including escaping if required
launcher_desktop_exec() {
	local application
	application="$1"

	# Enclose the path in single quotes if it includes spaces
	local field_format
	case "$OPTION_PREFIX" in
		(*' '*)
			field_format="Exec='%s'"
		;;
		(*)
			field_format='Exec=%s'
		;;
	esac

	# Use the full path for non-standard prefixes
	local field_value
	case "$OPTION_PREFIX" in
		('/usr'|'/usr/local')
			field_value=$(application_id "$application")
		;;
		(*)
			field_value="$PATH_BIN/$(application_id "$application")"
		;;
	esac

	# shellcheck disable=SC2059
	printf "$field_format" "$field_value"
}

# write both launcher script and menu entry for a single application
# USAGE: launcher_write $application
# CALLS: launcher_write_script launcher_write_desktop
# CALLED BY: launchers_write
launcher_write() {
	local application
	application="$1"
	launcher_write_script "$application"
	launcher_write_desktop "$application"
	return 0
}

# write both a launcher script and a menu entry for each application from a list
# USAGE: launchers_write [$application…]
# RETURN: nothing
launchers_write() {
	debug_entering_function 'launchers_write' 2

	# If called with no argument, default to handling the full list of applications
	if [ $# -eq 0 ]; then
		local applications_list
		applications_list=$(applications_list)

		# Calling launchers_write with no explicit arguments is not supported
		# if the applications list is empty
		if [ -z "$applications_list" ]; then
			error_applications_list_empty
			return 1
		fi

		launchers_write $applications_list
		debug_leaving_function 'launchers_write' 2
		return 0
	fi

	# Write a launcher script and a menu entry for each application
	local application
	for application in "$@"; do
		launcher_write "$application"
	done

	debug_leaving_function 'launchers_write' 2
}

