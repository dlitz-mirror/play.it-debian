# write launcher script
# USAGE: launcher_write_script $app
launcher_write_script() {
	# check that this has been called with exactly one argument
	if [ "$#" -eq 0 ]; then
		error_missing_argument 'launcher_write_script'
	elif [ "$#" -gt 1 ]; then
		error_extra_arguments 'launcher_write_script'
	fi

	# get the current package
	local package
	package=$(package_get_current)

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	# skip any action if called for a package excluded for target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${packages_list##*$package*}" ]; then
		warning_skip_package 'launcher_write_script' "$package"
		return 0
	fi

	# parse argument
	local application
	application="$1"
	if ! testvar "$application" 'APP'; then
		error_invalid_argument 'application' 'launcher_write_script'
	fi

	# compute file path
	# shellcheck disable=SC2039
	local target_file
	target_file="$(package_get_path "$package")${PATH_BIN}/$(application_id "$application")"

	# Check that the launcher target exists
	local binary_path binary_found tested_package
	case "$(application_type "$application")" in
		('residualvm'|'scummvm'|'renpy')
			# ResidualVM, ScummVM and Ren'Py games do not rely on a provided binary
		;;
		('mono')
			# Game binary for Mono games may be included in another package than the binaries one
			binary_found=0
			for tested_package in $packages_list; do
				binary_path="$(package_get_path "$tested_package")${PATH_GAME}/$(application_exe "$application")"
				if [ -f "$binary_path" ]; then
					binary_found=1
					break;
				fi
			done
			if \
				[ $DRY_RUN -eq 0 ] && \
				[ $binary_found -eq 0 ]
			then
				binary_path="$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
				error_launcher_missing_binary "$binary_path"
			fi
		;;
		('wine')
			if [ "$(application_exe "$application")" != 'winecfg' ]; then
				binary_path="$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
				if \
					[ $DRY_RUN -eq 0 ] && \
					[ ! -f "$binary_path" ]
				then
					error_launcher_missing_binary "$binary_path"
				fi
			fi
		;;
		(*)
			binary_path="$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
			if \
				[ $DRY_RUN -eq 0 ] && \
				[ ! -f "$binary_path" ]
			then
				error_launcher_missing_binary "$binary_path"
			fi
		;;
	esac

	# if called in dry run mode, return before writing anything
	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	# write launcher script
	debug_write_launcher "$(application_type "$application")" "$binary_file"
	mkdir --parents "$(dirname "$target_file")"
	touch "$target_file"
	chmod 755 "$target_file"
	launcher_write_script_headers "$target_file"
	case "$(application_type "$application")" in
		('dosbox')
			launcher_write_script_dosbox_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_dosbox_run "$application" "$target_file"
		;;
		('java')
			launcher_write_script_java_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_java_run "$application" "$target_file"
		;;
		('native')
			launcher_write_script_native_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_native_run "$application" "$target_file"
		;;
		('native_no-prefix')
			launcher_write_script_native_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_nativenoprefix_run "$application" "$target_file"
		;;
		('scummvm')
			launcher_write_script_scummvm_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_scummvm_run "$application" "$target_file"
		;;
		('renpy')
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_renpy_run "$application" "$target_file"
		;;
		('residualvm')
			launcher_write_script_residualvm_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_residualvm_run "$application" "$target_file"
		;;
		('wine')
			if [ "$(application_id "$application")" != "${GAME_ID}_winecfg" ]; then
				launcher_write_script_wine_application_variables "$application" "$target_file"
			fi
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_wine_prefix_build "$target_file"
			if [ "$(application_id "$application")" = "${GAME_ID}_winecfg" ]; then
				launcher_write_script_winecfg_run "$target_file"
			else
				launcher_write_script_wine_run "$application" "$target_file"
			fi
		;;
		('mono')
			launcher_write_script_mono_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_mono_run "$application" "$target_file"
		;;
	esac
	cat >> "$target_file" <<- 'EOF'
	exit 0
	EOF

	# for native applications, add execution permissions to the game binary file
	case "$(application_type "$application")" in
		('native'*)
			chmod +x "$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
		;;
	esac

	# for WINE applications, write launcher script for winecfg
	case "$(application_type "$application")" in
		('wine')
			local winecfg_file
			winecfg_file="$(package_get_path "$package")${PATH_BIN}/${GAME_ID}_winecfg"
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
# NEEDED VARS: GAME_ID PATH_GAME
# CALLED BY: launcher_write_script
launcher_write_script_game_variables() {
	local file
	file="$1"
	cat >> "$file" <<- EOF
	# Set game-specific values

	GAME_ID='$GAME_ID'
	PATH_GAME='$PATH_GAME'

	EOF
	return 0
}

# write launcher script list of user-writable files
# USAGE: launcher_write_script_user_files $file
# NEEDED VARS: CONFIG_DIRS CONFIG_FILES DATA_DIRS DATA_FILES
# CALLED BY: launcher_write_script
launcher_write_script_user_files() {
	local file
	file="$1"
	cat >> "$file" <<- EOF
	# Set list of user-writable files

	CONFIG_DIRS='$CONFIG_DIRS'
	CONFIG_FILES='$CONFIG_FILES'
	DATA_DIRS='$DATA_DIRS'
	DATA_FILES='$DATA_FILES'

	EOF
	return 0
}

# write launcher script prefix-related variables
# USAGE: launcher_write_script_prefix_variables $file
# CALLED BY: launcher_write_script
launcher_write_script_prefix_variables() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Set prefix-related values

	: "${PREFIX_ID:="$GAME_ID"}"
	PATH_CONFIG="${XDG_CONFIG_HOME:="$HOME/.config"}/$PREFIX_ID"
	PATH_DATA="${XDG_DATA_HOME:="$HOME/.local/share"}/games/$PREFIX_ID"

	EOF
	return 0
}

# write launcher script prefix functions
# USAGE: launcher_write_script_prefix_functions $file
# CALLED BY: launcher_write_script
launcher_write_script_prefix_functions() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Set localization and error reporting functions

	# select strings matching the current locale
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: localize $string[…]
	localize() {
	    local lang
	    local string
	    local match
	    for lang in "${LANG%%_*}" 'en'; do
	        for string in "$@"; do
	            if [ "${string%%:*}" = "$lang" ]; then
	                echo "${string#*:}"
	                match=1
	            fi
	        done
	        if [ "$match" ]; then
	            break
	        fi
	    done
	}

	# print a localized message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_message $string[…]
	display_message() {
	    local string
	    localize "$@" | while read -r string; do
	        printf "$string\n"
	    done 1>&2
	}

	# print a localized error message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_error $string[…]
	display_error() {
	    display_message \
	        'en:\033[1;31mError:\033[0m' \
	        'fr:\033[1;31mErreur :\033[0m'
	    display_message "$@"
	}

	# print a localized warning message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_warning $string[…]
	display_warning() {
	    display_message \
	        'en:\033[1;33mWarning:\033[0m' \
	        'fr:\033[1;33mAvertissement :\033[0m'
	    display_message "$@"
	}

	# Set userdir- and prefix-related functions

	# convert the name of specified user files and directories to upper case
	# note that only the last component of each matching path is converted
	# USAGE: userdir_toupper_files $userdir $list
	userdir_toupper_files() {
	    local userdir
	    local list
	    userdir="$1"
	    list="$2"
	    (
	        cd "$userdir"
	        for file in $list; do
	            [ -e "$file" ] || continue
	            newfile=$(dirname "$file")/$(basename "$file" | tr '[:lower:]' '[:upper:]')
	            if [ ! -e "$newfile" ]; then
	                mv "$file" "$newfile"
	            else
	                display_warning \
	                    "en:Cannot overwrite '$userdir/${newfile#./}' with '$userdir/$file'" \
	                    "fr:Impossible d'écraser '$userdir/${newfile#./}' par '$userdir/$file'"
	            fi
	        done
	    )
	}

	init_prefix_dirs() {
	    # shellcheck disable=SC2039
	    local destination directories
	    destination="$1"
	    directories="$2"
	    (
	        cd "$PATH_GAME"
	        for directory in $directories; do
	            mkdir --parents "${destination}/${directory}"
	            mkdir --parents "$(dirname "${PATH_PREFIX}/${directory}")"
	            if \
	                [ -d "${PATH_PREFIX}/${directory}" ] && \
	                [ ! -h "${PATH_PREFIX}/${directory}" ]
	            then
	                # Migrate existing data from the prefix
	                (
	                    cd "$PATH_PREFIX"
	                    find "$directory" -type f | while read -r file; do
	                        cp --parents --remove-destination "$file" "$destination"
	                        rm "$file"
	                    done
	                    find "$directory" -type l | while read -r link; do
	                        cp --parents --dereference --no-clobber "$link" "$destination"
	                        rm "$link"
	                    done
	                )
	                rm --recursive "${PATH_PREFIX:?}/${directory:?}"
	            fi
	            ln --force --symbolic --no-target-directory "${destination}/${directory}" "${PATH_PREFIX}/${directory}"
	        done
	    )
	}

	init_prefix_files() {
	    (
	        local file_prefix
	        local file_real
	        cd "$1"
	        find -L . -type f | while read -r file; do
	            if [ -e "$PATH_PREFIX/$file" ]; then
	                file_prefix="$(readlink -e "$PATH_PREFIX/$file")"
	            else
	                unset file_prefix
	            fi
	            file_real="$(readlink -e "$file")"
	            if [ "$file_real" != "$file_prefix" ]; then
	                if [ "$file_prefix" ]; then
	                    rm --force "$PATH_PREFIX/$file"
	                fi
	                mkdir --parents "$PATH_PREFIX/$(dirname "$file")"
	                ln --symbolic "$file_real" "$PATH_PREFIX/$file"
	            fi
	        done
	    )
	    (
	        cd "$PATH_PREFIX"
	        for file in $2; do
	            if [ -e "$file" ] && [ ! -e "$1/$file" ]; then
	                cp --parents "$file" "$1"
	                rm --force "$file"
	                ln --symbolic "$1/$file" "$file"
	            fi
	        done
	    )
	}

	init_userdir_files() {
	    (
	        cd "$PATH_GAME"
	        for file in $2; do
	            if [ ! -e "$1/$file" ] && [ -e "$file" ]; then
	                cp --parents "$file" "$1"
	            fi
	        done
	    )
	}

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix prepare hook
# USAGE: launcher_write_script_prefix_prepare $file
# CALLED BY: launcher_write_script_prefix_build launcher_write_script_wine_prefix_build
launcher_write_script_prefix_prepare() {
	local file
	file="$1"

	if [ "$PREFIX_PREPARE" ]; then
		cat >> "$file" <<- EOF
		$PREFIX_PREPARE

		EOF
	fi

	return 0
}

# write launcher script prefix initialization
# USAGE: launcher_write_script_prefix_build $file
# CALLED BY: launcher_write_build
launcher_write_script_prefix_build() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Build user prefix

	PATH_PREFIX="$XDG_DATA_HOME/play.it/prefixes/$PREFIX_ID"
	mkdir --parents \
	    "$PATH_PREFIX" \
	    "$PATH_CONFIG" \
	    "$PATH_DATA"
	EOF

	launcher_write_script_prefix_prepare "$file"

	cat >> "$file" <<- 'EOF'
	(
	    cd "$PATH_GAME"
	    find . -type d | while read -r dir; do
	        if [ -h "$PATH_PREFIX/$dir" ]; then
	            rm "$PATH_PREFIX/$dir"
	        fi
	    done
	)
	cp --recursive --remove-destination --symbolic-link "$PATH_GAME"/* "$PATH_PREFIX"
	(
	    cd "$PATH_PREFIX"
	    find . -type l | while read -r link; do
	        if [ ! -e "$link" ]; then
	            rm "$link"
	        fi
	    done
	    find . -depth -type d | while read -r dir; do
	        if [ ! -e "$PATH_GAME/$dir" ]; then
	            rmdir --ignore-fail-on-non-empty "$dir"
	        fi
	    done
	)

	# Use persistent storage for user data
	init_prefix_dirs   "$PATH_CONFIG" "$CONFIG_DIRS"
	init_prefix_dirs   "$PATH_DATA"   "$DATA_DIRS"
	init_userdir_files "$PATH_CONFIG" "$CONFIG_FILES"
	init_userdir_files "$PATH_DATA"   "$DATA_FILES"
	init_prefix_files  "$PATH_CONFIG" "$CONFIG_FILES"
	init_prefix_files  "$PATH_DATA"   "$DATA_FILES"

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script pre-run actions
# USAGE: launcher_write_script_prerun $application $file
launcher_write_script_prerun() {
	# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
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

# write menu entry
# USAGE: launcher_write_desktop $app
# NEEDED VARS: OPTION_ARCHITECTURE GAME_ID GAME_NAME PATH_DESK PATH_BIN
# CALLS: error_missing_argument error_extra_arguments
launcher_write_desktop() {
	# check that this has been called with exactly one argument
	if [ "$#" -eq 0 ]; then
		error_missing_argument 'launcher_write_desktop'
	elif [ "$#" -gt 1 ]; then
		error_extra_arguments 'launcher_write_desktop'
	fi

	# get the current package
	local package
	package=$(package_get_current)

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	# skip any action if called for a package excluded for target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${packages_list##*$package*}" ]; then
		warning_skip_package 'launcher_write_desktop' "$package"
		return 0
	fi

	# parse argument
	local application
	application="$1"
	if ! testvar "$application" 'APP'; then
		error_invalid_argument 'application' 'launcher_write_desktop'
	fi

	# compute file name and path
	local target_file
	target_file="$(package_get_path "$package")${PATH_DESK}/$(application_id "$application").desktop"

	# get icon name
	# shellcheck disable=SC2039
	local application_icon
	if [ "$application" = 'APP_WINECFG' ]; then
		application_icon='winecfg'
	else
		application_icon=$(application_id "$application")
	fi

	# if called in dry run mode, return before writing anything
	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	# write desktop file
	mkdir --parents "$(dirname "$target_file")"
	cat >> "$target_file" <<- EOF
	[Desktop Entry]
	Version=1.0
	Type=Application
	Name=$(application_name "$application")
	Icon=$application_icon
	Exec=$exec_field
	Categories=$(application_category "$application")
	EOF

	# for WINE applications, write desktop file for winecfg
	if [ "$application" != 'APP_WINECFG' ]; then
		case "$(application_type "$application")" in
			('wine')
				local winecfg_desktop
				winecfg_desktop="$(package_get_path "$package")${PATH_DESK}/${GAME_ID}_winecfg.desktop"
				if [ ! -e "$winecfg_desktop" ]; then
					export APP_WINECFG_ID="${GAME_ID}_winecfg"
					export APP_WINECFG_NAME="$GAME_NAME - WINE configuration"
					export APP_WINECFG_CAT='Settings'
					launcher_write_desktop 'APP_WINECFG'
				fi
			;;
		esac
	fi

	return 0
}

# print the content of the XDG desktop file for the given application
# USAGE: launcher_desktop $application
# RETURN: the full content of the XDG desktop file
launcher_desktop() {
	# shellcheck disable=SC2039
	local application
	application="$1"

	###
	# TODO
	# This should be moved to a dedicated function,
	# probably in a 20_icons.sh source file
	###
	# get icon name
	# shellcheck disable=SC2039
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

# print the XDG desktop "Exec" field for the given application
# USAGE: launcher_desktop_exec $application
# RETURN: the "Exec" field string, including escaping if required
launcher_desktop_exec() {
	# shellcheck disable=SC2039
	local application
	application="$1"

	# Enclose the path in single quotes if it includes spaces
	# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
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
# NEEDED VARS: OPTION_ARCHITECTURE
# CALLS: launcher_write_script launcher_write_desktop
# CALLED BY: launchers_write
launcher_write() {
	# get the current package
	local package
	package=$(package_get_current)

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	# skip any action if called for a package excluded for target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${packages_list##*$package*}" ]; then
		warning_skip_package 'launcher_write_script' "$package"
		return 0
	fi

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

	# Skip any action if called for a package excluded for target architectures
	if \
		[ "$OPTION_ARCHITECTURE" != 'all' ] \
		&& \
		! packages_get_list | grep --quiet "$(package_get_current)"
	then
		warning_skip_package 'launcher_write_script' "$(package_get_current)"
		debug_leaving_function 'launchers_write' 2
		return 0
	fi

	# If called with no argument, default to handling the full list of applications
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		launchers_write $(applications_list)
		debug_leaving_function 'launchers_write' 2
		return 0
	fi

	# Write a launcher script and a menu entry for each application
	# shellcheck disable=SC2039
	local application
	for application in "$@"; do
		launcher_write "$application"
	done

	debug_leaving_function 'launchers_write' 2
}

