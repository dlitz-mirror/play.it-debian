# WINE - write application-specific variables
# USAGE: launcher_write_script_wine_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_wine_application_variables() {
	local application file
	application="$1"
	file="$2"
	local application_exe application_options
	application_exe=$(application_exe "$application")
	application_options=$(application_options "$application")

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$application_exe'
	APP_OPTIONS="$application_options"
	APP_WINE_LINK_DIRS="$APP_WINE_LINK_DIRS"

	EOF
	return 0
}

# WINE - write launcher script prefix initialization
# USAGE: launcher_write_script_wine_prefix_build $file
# NEEDED VARS: APP_WINETRICKS APP_REGEDIT
# CALLED BY: launcher_write_build
launcher_write_script_wine_prefix_build() {
	local file
	file="$1"

	# get the current package
	local package
	package=$(package_get_current)

	# compute WINE prefix architecture
	local architecture winearch
	architecture=$(get_context_specific_value 'archive' "${package}_ARCH")
	case "$architecture" in
		('32') winearch='win32' ;;
		('64') winearch='win64' ;;
	esac

	cat >> "$file" <<- EOF
	# Build user prefix

	WINEARCH='$winearch'
	EOF

	cat >> "$file" <<- 'EOF'
	: "${WINEDEBUG:=-all}"
	WINEDLLOVERRIDES='winemenubuilder.exe,mscoree,mshtml=d'
	WINEPREFIX="$XDG_DATA_HOME/play.it/prefixes/$PREFIX_ID"
	# Work around WINE bug 41639
	FREETYPE_PROPERTIES="truetype:interpreter-version=35"

	PATH_PREFIX="$WINEPREFIX/drive_c/$GAME_ID"

	export WINEARCH WINEDEBUG WINEDLLOVERRIDES WINEPREFIX FREETYPE_PROPERTIES

	if ! [ -e "$WINEPREFIX" ]; then
	    mkdir --parents "$(dirname "$WINEPREFIX")"
	    # Use LANG=C to avoid localized directory names
	    LANG=C wineboot --init 2>/dev/null
	EOF

	if version_is_at_least '2.8' "$target_version"; then
		cat >> "$file" <<- 'EOF'
		    # Remove most links pointing outside of the WINE prefix
		    rm "$WINEPREFIX/dosdevices/z:"
		    find "$WINEPREFIX/drive_c/users/$(whoami)" -type l | while read -r directory; do
		        rm "$directory"
		        mkdir "$directory"
		    done
		EOF
	fi

	{
		# Set compatibility links to legacy user paths
		launcher_wine_user_legacy_link 'AppData/Roaming' 'Application Data'
		launcher_wine_user_legacy_link 'Documents' 'My Documents'
	} >> "$file"

	if [ "$APP_WINETRICKS" ]; then
		cat >> "$file" <<- EOF
		    if [ -t 0 ] || command -v zenity kdialog >/dev/null; then
		        winetricks $APP_WINETRICKS
		    elif command -v xterm >/dev/null; then
		        xterm -e winetricks $APP_WINETRICKS
		    else
		        winetricks $APP_WINETRICKS
		    fi
		    sleep 1s
		EOF
	fi

	if [ "$APP_REGEDIT" ]; then
		cat >> "$file" <<- EOF
		    for reg_file in $APP_REGEDIT; do
		EOF
		cat >> "$file" <<- 'EOF'
		    (
		        cd "$WINEPREFIX/drive_c/"
		        cp "$PATH_GAME/$reg_file" .
		        reg_file_basename="$(basename "$reg_file")"
		        wine regedit "$reg_file_basename"
		        rm "$reg_file_basename"
		    )
		    done
		EOF
	fi

	cat >> "$file" <<- 'EOF'
	fi

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

	# Move files that should be diverted to persistent paths to the game directory
	printf '%s' "$APP_WINE_LINK_DIRS" | grep ':' | while read -r line; do
	    prefix_dir="$PATH_PREFIX/${line%%:*}"
	    wine_dir="$WINEPREFIX/drive_c/${line#*:}"
	    if [ ! -h "$wine_dir" ]; then
	        mkdir --parents "$prefix_dir"
	        if [ -d "$wine_dir" ]; then
	            # Migrate existing user data to the persistent path
	            find "$prefix_dir" -type l -delete
	            cp --no-target-directory --recursive --remove-destination "$wine_dir" "$prefix_dir"
	            rm --recursive "$wine_dir"
	        fi
	        mkdir --parents "$(dirname "$wine_dir")"
	        ln --symbolic "$prefix_dir" "$wine_dir"
	    fi
	done

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
# CALLS: launcher_write_script_prerun launcher_write_script_postrun
# CALLED BY: launcher_write_script
launcher_write_script_wine_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF

	launcher_write_script_prerun "$application" "$file"

	cat >> "$file" <<- 'EOF'
	wine "$APP_EXE" $APP_OPTIONS "$@"

	EOF

	launcher_write_script_postrun "$application" "$file"

	return 0
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

	winecfg

	EOF

	return 0
}

# WINE - Set compatibility link to legacy user path
# USAGE: launcher_wine_user_legacy_link $path_current $path_legacy
# RETURN: the code snippet setting the compatibility links,
#         indented with 4 spaces
launcher_wine_user_legacy_link() {
	local path_current path_legacy
	path_current="$1"
	path_legacy="$2"
	cat <<- 'EOF'
	# Set compatibility link to a legacy user path
	user_directory="${WINEPREFIX}/drive_c/users/${USER}"
	EOF
	cat <<- EOF
	path_current='${path_current}'
	path_legacy='${path_legacy}'
	EOF
	cat <<- 'EOF'
	(
	    cd "$user_directory"
	    if [ ! -e "${user_directory}/${path_current}" ]; then
	        path_current_parent=$(dirname "$path_current")
	        mkdir --parents "$path_current_parent"
	        mv "$path_legacy" "$path_current"
	    fi
	    ln --symbolic "$path_current" "$path_legacy"
	)

	EOF
}

