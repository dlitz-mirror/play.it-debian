# Write launcher script for the given application
# USAGE: launcher_write_script $application
launcher_write_script() {
	local application
	application="$1"
	assert_not_empty 'application' 'launcher_write_script'
	if ! testvar "$application" 'APP'; then
		error_invalid_argument 'application' 'launcher_write_script'
		return 1
	fi

	# compute file path
	local package package_path path_binaries application_id target_file
	package=$(package_get_current)
	package_path=$(package_get_path "$package")
	path_binaries=$(path_binaries)
	application_id=$(application_id "$application")
	target_file="${package_path}${path_binaries}/${application_id}"

	# Get application type and prefix type
	local application_type prefix_type
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
	prefix_type=$(application_prefix_type "$application")

	# Check that the launcher target exists
	if ! launcher_target_presence_check "$application"; then
		local application_exe
		application_exe=$(application_exe "$application")
		error_launcher_missing_binary "$application_exe"
		return 1
	fi

	# write launcher script
	debug_write_launcher "$application_type" "$binary_file"
	mkdir --parents "$(dirname "$target_file")"
	touch "$target_file"
	chmod 755 "$target_file"
	launcher_write_script_headers "$target_file"
	case "$application_type" in
		('dosbox')
			case "$prefix_type" in
				('symlinks')
					dosbox_launcher_application_variables "$application" >> "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_print_persistent_paths >> "$target_file"
					launcher_write_script_prefix_functions "$target_file"
					dosbox_prefix_function_toupper >> "$target_file"
					launcher_write_script_prefix_build "$target_file"
					dosbox_launcher_run "$application" >> "$target_file"
					launcher_write_script_prefix_cleanup "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
		;;
		('java')
			case "$prefix_type" in
				('symlinks')
					java_launcher_application_variables "$application" >> "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_print_persistent_paths >> "$target_file"
					launcher_write_script_prefix_functions "$target_file"
					launcher_write_script_prefix_build "$target_file"
					java_launcher_run "$application" >> "$target_file"
					launcher_write_script_prefix_cleanup "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
		;;
		('native')
			case "$prefix_type" in
				('symlinks')
					native_launcher_application_variables "$application" >> "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_print_persistent_paths >> "$target_file"
					launcher_write_script_prefix_functions "$target_file"
					launcher_write_script_prefix_build "$target_file"
					native_launcher_run "$application" >> "$target_file"
					launcher_write_script_prefix_cleanup "$target_file"
				;;
				('none')
					native_launcher_application_variables "$application" >> "$target_file"
					launcher_write_script_game_variables "$target_file"
					native_launcher_run "$application" >> "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
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
			case "$prefix_type" in
				('none')
					scummvm_launcher_application_variables "$application" >> "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_write_script_prerun "$application" "$target_file"
					scummvm_launcher_run >> "$target_file"
					launcher_write_script_postrun "$application" "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
		;;
		('renpy')
			case "$prefix_type" in
				('symlinks')
					launcher_write_script_game_variables "$target_file"
					launcher_print_persistent_paths >> "$target_file"
					launcher_write_script_prefix_functions "$target_file"
					launcher_write_script_prefix_build "$target_file"
					renpy_launcher_run "$application" >> "$target_file"
					launcher_write_script_prefix_cleanup "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
		;;
		('residualvm')
			case "$prefix_type" in
				('none')
					residualvm_launcher_application_variables "$application" >> "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_write_script_prerun "$application" "$target_file"
					residualvm_launcher_run >> "$target_file"
					launcher_write_script_postrun "$application" "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
		;;
		('unity3d')
			case "$prefix_type" in
				('symlinks')
					native_launcher_application_variables "$application" >> "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_print_persistent_paths >> "$target_file"
					launcher_write_script_prefix_functions "$target_file"
					launcher_write_script_prefix_build "$target_file"
					launcher_write_script_unity3d_run "$application" "$target_file"
					launcher_write_script_prefix_cleanup "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
		;;
		('wine')
			wine_launcher_write "$application" "$target_file"
		;;
		('mono')
			case "$prefix_type" in
				('symlinks')
					mono_launcher_application_variables "$application" >> "$target_file"
					launcher_write_script_game_variables "$target_file"
					launcher_print_persistent_paths >> "$target_file"
					launcher_write_script_prefix_functions "$target_file"
					launcher_write_script_prefix_build "$target_file"
					mono_launcher_run "$application" >> "$target_file"
					launcher_write_script_prefix_cleanup "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
		;;
	esac
	cat >> "$target_file" <<- 'EOF'
	if [ -n "$game_exit_status" ]; then
	    exit $game_exit_status
	else
	    exit 0
	fi
	EOF

	# for native applications, add execution permissions to the game binary file
	case "$application_type" in
		('native'|'unity3d')
			local binary_file path_game_data
			path_game_data=$(path_game_data)
			binary_file="$(package_get_path "$package")${path_game_data}/$(application_exe "$application")"
			chmod +x "$binary_file"
		;;
	esac

	# for WINE applications, write launcher script for winecfg
	case "$application_type" in
		('wine')
			local game_id winecfg_file
			game_id=$(game_id)
			winecfg_file="${package_path}${path_binaries}/${game_id}_winecfg"
			if [ ! -e "$winecfg_file" ]; then
				launcher_write_script_wine_winecfg "$application"
			fi
		;;
	esac

	return 0
}

# Check that the launcher target exists.
# USAGE: launcher_target_presence_check $application
launcher_target_presence_check() {
	local application application_type
	application="$1"
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi

	case "$application_type" in
		('residualvm'|'scummvm'|'renpy')
			# ResidualVM, ScummVM and Ren'Py games do not rely on a provided binary.
			return 0
		;;
		('wine')
			# winecfg is provided by WINE itself, not the game archive.
			local application_exe
			application_exe=$(application_exe "$application")
			if [ "$application_exe" = 'winecfg' ]; then
				return 0
			fi
		;;
	esac

	local application_exe application_exe_path
	application_exe=$(application_exe "$application")
	application_exe_path=$(application_exe_path "$application_exe")
	test -f "$application_exe_path"
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

	local game_id
	game_id=$(game_id)
	cat >> "$file" <<- EOF
	# Set game-specific values

	GAME_ID='${game_id}'
	PATH_GAME='$(path_game_data)'

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
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
	if \
		[ "$application_type" = 'wine' ] && \
		[ "$application" != 'APP_WINECFG' ]
	then
		local package package_path path_xdg_desktop game_id winecfg_desktop
		package=$(package_get_current)
		package_path=$(package_get_path "$package")
		path_xdg_desktop=$(path_xdg_desktop)
		game_id=$(game_id)
		winecfg_desktop="${package_path}${path_xdg_desktop}/${game_id}_winecfg.desktop"
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
	local application application_id package package_path path_xdg_desktop
	application="$1"
	application_id=$(application_id "$application")
	package=$(package_get_current)
	package_path=$(package_get_path "$package")
	path_xdg_desktop=$(path_xdg_desktop)

	printf '%s/%s.desktop' \
		"${package_path}${path_xdg_desktop}" \
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
	local field_value application_id
	application_id=$(application_id "$application")
	case "$OPTION_PREFIX" in
		('/usr'|'/usr/local')
			field_value="$application_id"
		;;
		(*)
			local path_binaries
			path_binaries=$(path_binaries)
			field_value="${path_binaries}/${application_id}"
		;;
	esac

	# shellcheck disable=SC2059
	printf "$field_format" "$field_value"
}

# Write both the launcher script and menu entry for the given application
# USAGE: launcher_write $application
launcher_write() {
	local application
	application="$1"
	assert_not_empty 'application' 'launcher_write'

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

