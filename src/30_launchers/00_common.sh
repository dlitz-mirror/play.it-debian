# Print the path to the launcher script for the given application.
# USAGE: launcher_path $application
# RETURN: The absolute path to the launcher
launcher_path() {
	local application
	application="$1"

	local package package_path path_binaries application_id target_file
	package=$(context_package)
	package_path=$(package_path "$package")
	path_binaries=$(path_binaries)
	application_id=$(application_id "$application")

	printf '%s%s/%s' "$package_path" "$path_binaries" "$application_id"
}

# Write launcher script for the given application
# USAGE: launcher_write_script $application
launcher_write_script() {
	local application
	application="$1"
	assert_not_empty 'application' 'launcher_write_script'

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
		## Check that application binary has been found
		if [ -z "$application_exe" ]; then
			error_application_exe_empty "$application" 'launcher_write_script'
			return 1
		fi
		error_launcher_missing_binary "$application_exe"
		return 1
	fi

	# write launcher script
	local target_file
	debug_write_launcher "$application_type" "$binary_file"
	target_file=$(launcher_path "$application")
	mkdir --parents "$(dirname "$target_file")"
	touch "$target_file"
	chmod 755 "$target_file"
	launcher_headers > "$target_file"
	case "$application_type" in
		('dosbox')
			case "$prefix_type" in
				('symlinks')
					{
						dosbox_launcher_application_variables "$application"
						launcher_game_variables
						launcher_print_persistent_paths
						launcher_prefix_symlinks_functions
						dosbox_prefix_function_toupper
						launcher_prefix_symlinks_build
						dosbox_launcher_run "$application"
						launcher_prefix_symlinks_cleanup
					} >> "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
			local package
			package=$(context_package)
			dependencies_add_generic "$package" 'dosbox'
		;;
		('java')
			case "$prefix_type" in
				('symlinks')
					{
						java_launcher_application_variables "$application"
						launcher_game_variables
						launcher_print_persistent_paths
						launcher_prefix_symlinks_functions
						launcher_prefix_symlinks_build
						java_launcher_run "$application"
						launcher_prefix_symlinks_cleanup
					} >> "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
			local package
			package=$(context_package)
			dependencies_add_generic "$package" 'java'
		;;
		('native')
			case "$prefix_type" in
				('symlinks')
					{
						native_launcher_application_variables "$application"
						launcher_game_variables
						launcher_print_persistent_paths
						launcher_prefix_symlinks_functions
						launcher_prefix_symlinks_build
						native_launcher_run "$application"
						launcher_prefix_symlinks_cleanup
					} >> "$target_file"
				;;
				('none')
					{
						native_launcher_application_variables "$application"
						launcher_game_variables
						native_launcher_run "$application"
					} >> "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
		;;
		('scummvm')
			case "$prefix_type" in
				('none')
					{
						scummvm_launcher_application_variables "$application"
						launcher_game_variables
						application_prerun "$application"
						scummvm_launcher_run
						application_postrun "$application"
					} >> "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
			local package
			package=$(context_package)
			dependencies_add_generic "$package" 'scummvm'
		;;
		('renpy')
			case "$prefix_type" in
				('symlinks')
					{
						launcher_game_variables
						launcher_print_persistent_paths
						launcher_prefix_symlinks_functions
						launcher_prefix_symlinks_build
						renpy_launcher_run "$application"
						launcher_prefix_symlinks_cleanup
					} >> "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
			local package
			package=$(context_package)
			dependencies_add_generic "$package" 'renpy'
		;;
		('residualvm')
			case "$prefix_type" in
				('none')
					{
						residualvm_launcher_application_variables "$application"
						launcher_game_variables
						application_prerun "$application"
						residualvm_launcher_run
						application_postrun "$application"
					} >> "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
			local package
			package=$(context_package)
			dependencies_add_generic "$package" 'residualvm'
		;;
		('wine')
			wine_launcher "$application" >> "$target_file"
			local package
			package=$(context_package)
			dependencies_add_generic "$package" 'wine'
		;;
		('mono')
			case "$prefix_type" in
				('symlinks')
					{
						mono_launcher_application_variables "$application"
						launcher_game_variables
						launcher_print_persistent_paths
						launcher_prefix_symlinks_functions
						launcher_prefix_symlinks_build
						mono_launcher_run "$application"
						launcher_prefix_symlinks_cleanup
					} >> "$target_file"
				;;
				('none')
					{
						mono_launcher_application_variables "$application"
						launcher_game_variables
						mono_launcher_run "$application"
					} >> "$target_file"
				;;
				(*)
					error_launchers_prefix_type_unsupported "$application"
					return 1
				;;
			esac
			local package
			package=$(context_package)
			dependencies_add_generic "$package" 'mono'
		;;
	esac
	launcher_exit >> "$target_file"

	# The generated launcher scripts use spaces for indentation,
	# these must be replaced with tabulations.
	sed --in-place --regexp-extended 's/( ){4}/\t/g' "$target_file"

	# For native applications, add execution permissions to the game binary file.
	case "$application_type" in
		('native')
			local application_exe application_exe_path
			application_exe=$(application_exe "$application")
			## Check that application binary has been found
			if [ -z "$application_exe" ]; then
				error_application_exe_empty "$application" 'launcher_write_script'
				return 1
			fi
			application_exe_path=$(application_exe_path "$application_exe")
			chmod +x "$application_exe_path"
		;;
	esac
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
	esac

	local application_exe application_exe_path
	application_exe=$(application_exe "$application")
	## Check that application binary has been found
	if [ -z "$application_exe" ]; then
		error_application_exe_empty "$application" 'launcher_target_presence_check'
		return 1
	fi
	application_exe_path=$(application_exe_path "$application_exe")
	test -f "$application_exe_path"
}

# Print the headers common to all launcher scripts
# USAGE: launcher_headers
launcher_headers() {
	cat <<- EOF
	#!/bin/sh
	# script generated by ./play.it $LIBRARY_VERSION - https://www.dotslashplay.it/
	set -o errexit

	EOF
}

# Print the exit actions common to all launcher scripts
# USAGE: launcher_exit
launcher_exit() {
	cat <<- 'EOF'
	# Return the game exit code

	if [ -n "$game_exit_status" ]; then
	    exit "$game_exit_status"
	else
	    exit 0
	fi
	EOF
}

# Print the variables common to all launchers for the current game
# USAGE: launcher_game_variables
launcher_game_variables() {
	local game_id path_game_data
	game_id=$(game_id)
	path_game_data=$(path_game_data)
	cat <<- EOF
	# Set game-specific values

	GAME_ID='$game_id'
	PATH_GAME='$path_game_data'

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
}

# print the content of the XDG desktop file for the given application
# USAGE: launcher_desktop $application
# RETURN: the full content of the XDG desktop file
launcher_desktop() {
	local application
	application="$1"

	local application_name application_icon application_category launcher_desktop_exec
	application_name=$(application_name "$application")
	application_icon=$(application_id "$application")
	application_category=$(application_category "$application")
	launcher_desktop_exec=$(launcher_desktop_exec "$application")

	cat <<- EOF
	[Desktop Entry]
	Version=1.0
	Type=Application
	Name=$application_name
	Icon=$application_icon
	$launcher_desktop_exec
	Categories=$application_category
	EOF
}

# print the full path to the XDG desktop file for the given application
# USAGE: launcher_desktop_filepath $application
# RETURN: an absolute file path
launcher_desktop_filepath() {
	local application application_id package package_path path_xdg_desktop
	application="$1"
	application_id=$(application_id "$application")
	package=$(context_package)
	package_path=$(package_path "$package")
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
	local option_prefix field_format
	option_prefix=$(option_value 'prefix')
	case "$option_prefix" in
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
	case "$option_prefix" in
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

