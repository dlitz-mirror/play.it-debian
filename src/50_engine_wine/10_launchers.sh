# WINE - Compute path to WINE prefix
# USAGE: wine_prefix_wineprefix_path
wine_prefix_wineprefix_path() {
	cat <<- 'EOF'
	# Compute the path to WINE prefix for the current session
	wineprefix_path() {
	    # Prefix path can be explicitely set using an environment variable
	    if [ -n "$WINEPREFIX" ]; then
	        printf '%s' "$WINEPREFIX"
	        return 0
	    fi
	    # Compute the default prefix path if none has been explicitely set
	    printf '%s/play.it/wine/%s' \
	        "${XDG_CACHE_HOME:="$HOME/.cache"}" \
	        "$GAME_ID"
	}
	EOF
}

# WINE - Set WINE prefix environment
# USAGE: wine_prefix_wineprefix_environment
wine_prefix_wineprefix_environment() {
	# Compute WINE prefix architecture
	local package package_architecture wine_architecture
	package=$(package_get_current)
	package_architecture=$(get_context_specific_value 'archive' "${package}_ARCH")
	case "$package_architecture" in
		('32')
			wine_architecture='win32'
		;;
		('64')
			wine_architecture='win64'
		;;
	esac
	# Set variables used for WINE prefix
	cat <<- EOF
	# Set variables used for WINE prefix
	WINEARCH='$wine_architecture'
	WINEDEBUG="\${WINEDEBUG:=-all}"
	WINEPREFIX=\$(wineprefix_path)
	## Disable some WINE anti-features
	## - creation of desktop entries
	## - installation of Mono
	## - installation of Gecko
	WINEDLLOVERRIDES="\${WINEDLLOVERRIDES:=winemenubuilder.exe,mscoree,mshtml=}"
	## Work around WINE bug 41639 - Wine with freetype 2.7 causes font rendering issues
	## cf. https://bugs.winehq.org/show_bug.cgi?id=41639
	FREETYPE_PROPERTIES='truetype:interpreter-version=35'
	export WINEARCH WINEDEBUG WINEDLLOVERRIDES WINEPREFIX FREETYPE_PROPERTIES
	EOF
}

# WINE - Initial call to regedit during prefix generation
# USAGE: wine_prefix_wineprefix_regedit $regedit_script[…]
wine_prefix_wineprefix_regedit() {
	# Return early if no regedit call is required
	if [ $# -eq 0 ]; then
		return 0
	fi
	# Load registry scripts
	cat <<- EOF
	# Load registry scripts
	for regedit_script in $*; do
	    (
	        cd "\${WINEPREFIX}/drive_c/\${GAME_ID}"
	        printf 'Loading registry script: %s\n' "\$regedit_script"
	        \$(regedit_command) "\$regedit_script"
	    )
	done
	EOF
}

# WINE - Initial call to winetricks during prefix generation
# USAGE: launcher_wine_winetricks_call $winetricks_verb[…]
wine_prefix_wineprefix_winetricks() {
	# Return early if no winetricks call is required
	if [ $# -eq 0 ]; then
		return 0
	fi
	# Run initial winetricks call
	cat <<- EOF
	# Run initial winetricks call
	winetricks_wrapper $*
	EOF
}

# WINE - Set compatibility link to legacy user path
# USAGE: wine_prefix_wineprefix_legacy_link $path_current $path_legacy
wine_prefix_wineprefix_legacy_link() {
	local path_current path_legacy
	path_current="$1"
	path_legacy="$2"
	cat <<- EOF
	# Set compatibility link to a legacy user path
	user_directory="\${WINEPREFIX}/drive_c/users/\${USER}"
	path_current='${path_current}'
	path_legacy='${path_legacy}'
	(
	    cd "\$user_directory"
	    if [ ! -e "\${user_directory}/\${path_current}" ]; then
	        path_current_parent=\$(dirname "\$path_current")
	        mkdir --parents "\$path_current_parent"
	        mv "\$path_legacy" "\$path_current"
	    fi
	    ln --symbolic "\$path_current" "\$path_legacy"
	)
	EOF
}

# WINE - Print the snippet used to generate the WINE prefix
# USAGE: wine_prefix_wineprefix_build
wine_prefix_wineprefix_build() {
	# Compute path to WINE prefix
	wine_prefix_wineprefix_path
	# Set WINE prefix environment
	wine_prefix_wineprefix_environment
	# Generate the WINE prefix
	cat <<- 'EOF'
	# Generate the WINE prefix
	if ! [ -e "$WINEPREFIX" ]; then
	    mkdir --parents "$(dirname "$WINEPREFIX")"
	    # Use LANG=C to avoid localized directory names
	    LANG=C $(wineboot_command) --init 2>/dev/null
	    # Wait until the WINE prefix creation is complete
	    printf "Waiting for the WINE prefix initialization to complete, it might take a couple seconds…\\n"
	    while [ ! -f "${WINEPREFIX}/system.reg" ]; do
	        sleep 1s
	    done
	    # Link game prefix into WINE prefix
	    ln --symbolic \
	        "$PATH_PREFIX" \
	        "${WINEPREFIX}/drive_c/${GAME_ID}"
	    # Remove most links pointing outside of the WINE prefix
	    rm "$WINEPREFIX/dosdevices/z:"
	    find "$WINEPREFIX/drive_c/users/$(whoami)" -type l | while read -r directory; do
	        rm "$directory"
	        mkdir "$directory"
	    done
	EOF
	# Set compatibility links to legacy user paths
	wine_prefix_wineprefix_legacy_link 'AppData/Roaming' 'Application Data'
	wine_prefix_wineprefix_legacy_link 'Documents' 'My Documents'
	# Run initial winetricks call
	wine_prefix_wineprefix_winetricks $APP_WINETRICKS
	# Load registry scripts
	wine_prefix_wineprefix_regedit $APP_REGEDIT
	cat <<- 'EOF'
	fi
	EOF
}

# WINE - Set links required for persistent paths diversion
# USAGE: wine_prefix_persistent_links
wine_prefix_persistent_links() {
	cat <<- 'EOF'
	# Move files that should be diverted to persistent paths to the game directory
	printf '%s' "$APP_WINE_LINK_DIRS" | grep ':' | while read -r line; do
	    prefix_dir="$PATH_PREFIX/${line%%:*}"
	    wine_dir="$WINEPREFIX/drive_c/${line#*:}"
	    if [ ! -h "$wine_dir" ]; then
	        if [ -d "$wine_dir" ]; then
	            mv --no-target-directory "$wine_dir" "$prefix_dir"
	        fi
	        if [ ! -d "$prefix_dir" ]; then
	            mkdir --parents "$prefix_dir"
	        fi
	        mkdir --parents "$(dirname "$wine_dir")"
	        ln --symbolic "$prefix_dir" "$wine_dir"
	    fi
	done
	EOF
}

# WINE - Set environment for registry keys persistent storage
# USAGE: wine_persistent_regedit_environment
wine_persistent_regedit_environment() {
	cat <<- 'EOF'
	# Set environment for registry keys persistent storage
	USER_PERSISTENT_PATH_REGEDIT="${USER_PERSISTENT_PATH}/wine/regedit"
	REGEDIT_DUMPS_WINEPREFIX_PATH="${WINEPREFIX}/drive_c/${GAME_ID}/wine/regedit"
	EOF
	cat <<- EOF
	REGEDIT_PERSISTENT_KEYS='$WINE_REGEDIT_PERSISTENT_KEYS'
	EOF
	cat <<- 'EOF'
	# Convert registry key name to file path
	regedit_convert_key_to_path() {
	    printf '%s.reg' "$1" | \
	        sed 's#\\#/#g' | \
	        tr '[:upper:]' '[:lower:]'
	}
	EOF
}

# WINE - Store registry keys in a persistent path
# USAGE: wine_persistent_regedit_store
wine_persistent_regedit_store() {
	cat <<- 'EOF'
	# Store registry keys in a persistent path
	while read -r registry_key; do
	    if [ -z "$registry_key" ]; then
	        continue
	    fi
	    registry_dump="${REGEDIT_DUMPS_WINEPREFIX_PATH}/$(regedit_convert_key_to_path "$registry_key")"
	    registry_dump_directory=$(dirname "$registry_dump")
	    mkdir --parents "$registry_dump_directory"
	    printf 'Dumping registry key in "%s".\n' "$registry_dump"
	    $(regedit_command) -E "$registry_dump" "$registry_key"
	done <<- EOL
	$(printf '%s' "$REGEDIT_PERSISTENT_KEYS")
	EOL
	if [ -e "$REGEDIT_DUMPS_WINEPREFIX_PATH" ]; then
	    (
	        mkdir --parents "$USER_PERSISTENT_PATH_REGEDIT"
	        cd "$REGEDIT_DUMPS_WINEPREFIX_PATH"
	        find . -type f \
	            -exec cp --force --parents --target-directory="$USER_PERSISTENT_PATH_REGEDIT" {} +
	    )
	fi
	EOF
}

# WINE - Load registry keys from persistent dumps
# USAGE: wine_persistent_regedit_load
wine_persistent_regedit_load() {
	cat <<- 'EOF'
	# Load registry keys from persistent dumps
	if [ -e "$USER_PERSISTENT_PATH_REGEDIT" ]; then
	    (
	        mkdir --parents "$REGEDIT_DUMPS_WINEPREFIX_PATH"
	        cd "$USER_PERSISTENT_PATH_REGEDIT"
	        find . -type f \
	            -exec cp --force --parents --target-directory="$REGEDIT_DUMPS_WINEPREFIX_PATH" {} +
	    )
	fi
	while read -r registry_key; do
	    if [ -z "$registry_key" ]; then
	        continue
	    fi
	    registry_dump="${REGEDIT_DUMPS_WINEPREFIX_PATH}/$(regedit_convert_key_to_path "$registry_key")"
	    if [ -e "$registry_dump" ]; then
	        printf 'Loading registry key from "%s".\n' "$registry_dump"
	        $(regedit_command) "$registry_dump"
	    fi
	done <<- EOL
	$(printf '%s' "$REGEDIT_PERSISTENT_KEYS")
	EOL
	EOF
}

# print the snippet providing a function returning the path to the `wine` command
# USAGE: launcher_wine_command_path
# RETURN: the code snippet, a multi-lines string, indented with four spaces
launcher_wine_command_path() {
	cat <<- 'EOF'
	# Print the path to the `wine` command
	wine_command() {
	    if [ -z "$PLAYIT_WINE_CMD" ]; then
	        command -v wine
	        return 0
	    fi
	    printf '%s' "$PLAYIT_WINE_CMD"
	}
	winecfg_command() {
	    wine_command | sed 's#/wine$#/winecfg#'
	}
	wineboot_command() {
	    wine_command | sed 's#/wine$#/wineboot#'
	}
	wineserver_command() {
	    wine_command | sed 's#/wine$#/wineserver#'
	}
	regedit_command() {
	    wine_command | sed 's#/wine$#/regedit#'
	}

	EOF
}

# WINE - write application-specific variables
# USAGE: launcher_write_script_wine_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_wine_application_variables() {
	local application file
	application="$1"
	file="$2"
	local application_exe application_options
	application_exe=$(application_exe_escaped "$application")
	application_options=$(application_options "$application")

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$application_exe'
	APP_OPTIONS="$application_options"
	APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"

	EOF
	return 0
}

# WINE - write launcher script for winecfg
# USAGE: launcher_write_script_wine_winecfg $application
launcher_write_script_wine_winecfg() {
	local application
	application="$1"
	APP_WINECFG_ID="$(game_id)_winecfg"
	export APP_WINECFG_ID
	export APP_WINECFG_TYPE='wine'
	export APP_WINECFG_EXE='winecfg'
	launcher_write_script 'APP_WINECFG'
	return 0
}

# WINE - run the game
# USAGE: launcher_write_script_wine_run $application $file
launcher_write_script_wine_run() {
	local application file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "${WINEPREFIX}/drive_c/${GAME_ID}"
	EOF
	launcher_write_script_prerun "$application" "$file"
	cat >> "$file" <<- 'EOF'
	# Do not exit on application failure,
	# to ensure post-run commands are run.
	set +o errexit
	$(wine_command) "$APP_EXE" $APP_OPTIONS "$@"
	game_exit_status=$?
	set -o errexit
	EOF
	launcher_write_script_postrun "$application" "$file"
}

# WINE - run winecfg
# USAGE: launcher_write_script_winecfg_run $file
# CALLED BY: launcher_write_script
launcher_write_script_winecfg_run() {
	# parse arguments
	local file
	file="$1"

	cat >> "$file" <<- 'EOF'
	# Run WINE configuration

	$(winecfg_command)

	EOF

	return 0
}

# WINE - Apply winetricks verbs, spawning a terminal if required
# USAGE: wine_winetricks_wrapper
wine_winetricks_wrapper() {
	cat <<- 'EOF'
	# Apply winetricks verbs, spawning a terminal if required
	winetricks_wrapper() {
	    # Export custom paths to WINE commands
	    # so winetricks use them instead of the default paths
	    WINE=$(wine_command)
	    WINESERVER=$(wineserver_command)
	    WINEBOOT=$(wineboot_command)
	    export WINE WINESERVER WINEBOOT
	    # Run winetricks, spawning a terminal if required
	    # to ensure it is not silently running in the background
	    if [ -t 0 ] || command -v zenity kdialog >/dev/null; then
	        winetricks "$@"
	    elif command -v xterm >/dev/null; then
	        xterm -e winetricks "$@"
	    else
	        winetricks "$@"
	    fi
	    ## Wait a bit for lingering WINE processes to terminate
	    sleep 1s
	}
	EOF
}
