# write launcher script
# USAGE: launcher_write_script $app
launcher_write_script() {
	# check that this has been called with exactly one argument
	if [ "$#" -eq 0 ]; then
		error_missing_argument 'launcher_write_script'
		return 1
	elif [ "$#" -gt 1 ]; then
		error_extra_arguments 'launcher_write_script'
		return 1
	fi

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

	# Check that the launcher target exists
	local application_type binary_path binary_found tested_package
	application_type=$(application_type "$application")
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
			if \
				[ $DRY_RUN -eq 0 ] && \
				[ $binary_found -eq 0 ]
			then
				binary_path="$(package_get_path "$package")${PATH_GAME}/$(application_exe "$application")"
				error_launcher_missing_binary "$binary_path"
				return 1
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
					return 1
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
				return 1
			fi
		;;
	esac

	# if called in dry run mode, return before writing anything
	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

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
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_dosbox_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('java')
			launcher_write_script_java_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_java_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('native')
			launcher_write_script_native_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_native_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
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
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
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
			launcher_write_script_user_files "$target_file"
			launcher_wine_command_path >> "$target_file"
			launcher_write_script_prefix_variables "$target_file"
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
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
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
		('native'*|'unity3d')
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

	# create prefix and user config/data directories
	# USAGE: prefix_create_dirs
	prefix_create_dirs() {
	    for dir in "$PATH_PREFIX" "$PATH_CONFIG" "$PATH_DATA"; do
	        if [ ! -d "$dir" ]; then
	            mkdir --parents "$dir"
	        fi
	    done
	}

	# populate prefix with symbolic links to all game file
	# USAGE: prefix_init_game_files
	prefix_init_game_files() {
	    # remove symlinks to game directories
	    (
	        cd "$PATH_GAME"
	        find . -type d | while read -r dir; do
	            if [ -h "$PATH_PREFIX/$dir" ]; then
	                rm "$PATH_PREFIX/$dir"
	            fi
	        done
	    )
	    # populate prefix with symlinks to all game file
	    cp --recursive --remove-destination --symbolic-link --no-target-directory "$PATH_GAME" "$PATH_PREFIX"
	    # remove dangling links and non-game empty directories
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
	}

	# create symbolic link $PATH_PREFIX/$target -> $userdir/$target,
	# overwriting $PATH_PREFIX/$target if it exists
	# USAGE: prefix_symlink_to_userdir $userdir $target
	prefix_symlink_to_userdir() {
	    local userdir target target_prefix target_real
	    userdir="$1"
	    target="$2"
	    if [ -e "${PATH_PREFIX}/${target}" ]; then
	        target_prefix=$(readlink --canonicalize-existing "${PATH_PREFIX}/${target}")
	    else
	        unset target_prefix
	    fi
	    target_real=$(readlink --canonicalize-existing "${userdir}/${target}")
	    if [ "$target_real" != "$target_prefix" ]; then
	        if [ "$target_prefix" ]; then
	            rm --force --recursive "${PATH_PREFIX:?}/${target}"
	        fi
	        local target_parent
	        target_parent=$(dirname "$target")
	        mkdir --parents "${PATH_PREFIX}/${target_parent}"
	        ln --symbolic "$target_real" "${PATH_PREFIX}/${target}"
	    fi
	}

	# move $PATH_PREFIX/$target to $userdir/$target (overwriting it if it exists),
	# and create symbolic link $PATH_PREFIX/$target -> $userdir/$target
	# USAGE: prefix_move_to_userdir_and_symlink $userdir $target
	prefix_move_to_userdir_and_symlink() {
	    local userdir target
	    userdir="$1"
	    target="$2"
	    if [ -e "${userdir}/${target}" ]; then
	        rm --force --recursive "${userdir}/${target}"
	    fi
	    local target_parent
	    target_parent=$(dirname "$target")
	    mkdir --parents "${userdir}/${target_parent}"
	    cp --recursive --dereference --no-target-directory "${PATH_PREFIX}/${target}" "${userdir}/${target}"
	    rm --force --recursive "${PATH_PREFIX:?}/${target}"
	    ln --symbolic "${userdir}/${target}" "${PATH_PREFIX}/${target}"
	}

	# initialize prefix with user directories
	# USAGE: prefix_init_user_dirs $userdir $dirs
	prefix_init_user_dirs() {
	    local userdir
	    local dirs
	    userdir="$1"
	    dirs="$2"
	    # populate prefix with symlinks to specified directories
	    (
	        cd "$userdir"
	        for dir in $dirs; do
	            [ -d "$dir" ] || continue
	            prefix_symlink_to_userdir "$userdir" "$dir"
	        done
	    )
	    # move specified directories, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for dir in $dirs; do
	            [ -d "$dir" ] || continue
	            if [ ! -e "$userdir/$dir" ]; then
	                prefix_move_to_userdir_and_symlink "$userdir" "$dir"
	            elif [ ! -d "$userdir/$dir" ]; then
	                display_warning \
	                    "en:Cannot overwrite '$userdir/$dir' with directory '$PATH_PREFIX/$dir'" \
	                    "fr:Impossible d'écraser '$userdir/$dir' par le répertoire '$PATH_PREFIX/$dir'"
	            fi
	        done
	    )
	}

	# initialize prefix with user files
	# USAGE: prefix_init_user_files $userdir $files
	prefix_init_user_files() {
	    local userdir
	    local files
	    userdir="$1"
	    files="$2"
	    # populate prefix with symlinks to all files in user directory
	    (
	        cd "$userdir"
	        find -L . -type f | while read -r file; do
	            prefix_symlink_to_userdir "$userdir" "$file"
	        done
	    )
	    # move specified files, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for file in $files; do
	            [ -f "$file" ] || continue
	            if [ ! -e "$userdir/$file" ]; then
	                prefix_move_to_userdir_and_symlink "$userdir" "$file"
	            elif [ ! -f "$userdir/$file" ]; then
	                display_warning \
	                    "en:Cannot overwrite '$userdir/$file' with file '$PATH_PREFIX/$file'" \
	                    "fr:Impossible d'écraser '$userdir/$file' par le fichier '$PATH_PREFIX/$file'"
	            fi
	        done
	    )
	}

	# synchronize user directories with prefix
	# USAGE: prefix_sync_user_dirs $userdir $dirs
	prefix_sync_user_dirs() {
	    local userdir
	    local dirs
	    userdir="$1"
	    dirs="$2"
	    # move specified directories, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for dir in $dirs; do
	            [ -d "$dir" ] || continue
	            if [ ! -h "$dir" ]; then
	                if [ ! -e "$userdir/$dir" ] || [ -d "$userdir/$dir" ]; then
	                    prefix_move_to_userdir_and_symlink "$userdir" "$dir"
	                else
	                    display_warning \
	                        "en:Cannot overwrite '$userdir/$dir' with directory '$PATH_PREFIX/$dir'" \
	                        "fr:Impossible d'écraser '$userdir/$dir' par le répertoire '$PATH_PREFIX/$dir'"
	                fi
	            fi
	        done
	    )
	    # remove user directories which are not in the prefix anymore, if any
	    (
	        cd "$userdir"
	        for dir in $dirs; do
	            [ -d "$dir" ] || continue
	            if [ ! -e "$PATH_PREFIX/$dir" ]; then
	                rm --force --recursive "$dir"
	            fi
	        done
	    )
	}

	# synchronize user files with prefix
	# USAGE: prefix_sync_user_files $userdir $files
	prefix_sync_user_files() {
	    local userdir
	    local files
	    userdir="$1"
	    files="$2"
	    # move specified files, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for file in $files; do
	            [ -f "$file" ] || continue
	            if [ ! -h "$file" ]; then
	                if [ ! -e "$userdir/$file" ] || [ -f "$userdir/$file" ]; then
	                    prefix_move_to_userdir_and_symlink "$userdir" "$file"
	                else
	                    display_warning \
	                        "en:Cannot overwrite '$userdir/$file' with file '$PATH_PREFIX/$file'" \
	                        "fr:Impossible d'écraser '$userdir/$file' par le fichier '$PATH_PREFIX/$file'"
	                fi
	            fi
	        done
	    )
	    # remove user files which are not in the prefix anymore, if any
	    (
	        cd "$userdir"
	        for file in $files; do
	            [ -f "$file" ] || continue
	            if [ ! -e "$PATH_PREFIX/$file" ]; then
	                rm --force --recursive "$file"
	            fi
	        done
	    )
	}

	# create and initialize user prefix
	# USAGE: prefix_build
	prefix_build() {
	    local reply
	    # clean up the prefix if a lock file is still present from a previous run
	    if [ -e "$PREFIX_LOCK" ]; then
	        display_warning \
	            "en:The game prefix ('$PATH_PREFIX') was not properly cleaned up (possibly from a previous game crash)." \
	            "fr:Le répertoire de jeu ('$PATH_PREFIX') n'a pas été nettoyé correctement (possiblement à cause d'un précédent plantage du jeu)."
	        while true; do
	            display_message \
	                "en:Clean up the game prefix? [(Y)es/(n)o/(q)uit]" \
	                "fr:Nettoyer le répertoire de jeu ? [(O)ui/(n)on/(q)uitter]"
	            read reply || :
	            reply="$(echo "$reply" | tr '[:upper:]' '[:lower:]')"
	            if [ -z "$reply" ] || [ "$reply" = "$(localize 'en:y' 'fr:o')" ]; then
	                prefix_cleanup
	                break
	            elif [ "$reply" = "$(localize 'en:n' 'fr:n')" ]; then
	                break
	            elif [ "$reply" = "$(localize 'en:q' 'fr:q')" ]; then
	                exit 1
	            fi
	            display_warning \
	                "en:Invalid answer: '$reply'." \
	                "fr:Réponse invalide : '$reply'."
	        done
	    fi
	    prefix_create_dirs
	    prefix_init_game_files
	    prefix_init_user_dirs "$PATH_CONFIG" "$CONFIG_DIRS"
	    prefix_init_user_dirs "$PATH_DATA" "$DATA_DIRS"
	    prefix_init_user_files "$PATH_CONFIG" "$CONFIG_FILES"
	    prefix_init_user_files "$PATH_DATA" "$DATA_FILES"
	    touch "$PREFIX_LOCK"
	}

	# clean up and synchronize back user prefix
	# USAGE: prefix_cleanup
	prefix_cleanup() {
	    prefix_sync_user_dirs "$PATH_CONFIG" "$CONFIG_DIRS"
	    prefix_sync_user_dirs "$PATH_DATA" "$DATA_DIRS"
	    prefix_sync_user_files "$PATH_CONFIG" "$CONFIG_FILES"
	    prefix_sync_user_files "$PATH_DATA" "$DATA_FILES"
	    rm --force "$PREFIX_LOCK"
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
	PREFIX_LOCK="$PATH_PREFIX/.$GAME_ID.lock"
	mkdir --parents \
	    "$PATH_PREFIX" \
	    "$PATH_CONFIG" \
	    "$PATH_DATA"
	EOF

	launcher_write_script_prefix_prepare "$file"

	cat >> "$file" <<- 'EOF'
	prefix_build

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix cleanup
# USAGE: launcher_write_script_prefix_cleanup $file
# CALLED BY: launcher_write_build
launcher_write_script_prefix_cleanup() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Clean up user prefix

	prefix_cleanup

	EOF
	sed --in-place 's/    /\t/g' "$file"
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

	# if called in dry run mode, return before writing anything
	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	# write desktop file
	local desktop_file
	desktop_file=$(launcher_desktop_filepath "$application")
	mkdir --parents "$(dirname "$desktop_file")"
	launcher_desktop "$application" > "$desktop_file"

	# for WINE applications, write desktop file for winecfg
	if [ "$application" != 'APP_WINECFG' ]; then
		local application_type
		application_type=$(application_type "$application")
		case "$application_type" in
			('wine')
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
			;;
		esac
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
		# shellcheck disable=SC2046
		launchers_write $(applications_list)
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

