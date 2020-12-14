# WINE - write application-specific variables
# USAGE: launcher_write_script_wine_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_wine_application_variables() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	# compute application-specific variables values
	local application_exe
	local application_options
	use_package_specific_value "${application}_EXE"
	use_package_specific_value "${application}_OPTIONS"
	application_exe="$(get_value "${application}_EXE")"
	application_options="$(get_value "${application}_OPTIONS")"

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
	local architecture
	local winearch
	use_archive_specific_value "${package}_ARCH"
	architecture="$(get_value "${package}_ARCH")"
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

	if ! version_target_is_older_than '2.8'; then
		cat >> "$file" <<- 'EOF'
		    # Remove most links pointing outside of the WINE prefix
		    rm "$WINEPREFIX/dosdevices/z:"
		    find "$WINEPREFIX/drive_c/users/$(whoami)" -type l | while read -r directory; do
		        rm "$directory"
		        mkdir "$directory"
		    done
		EOF
	fi

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
	EOF

	cat >> "$file" <<- 'EOF'
	for dir in "$PATH_PREFIX" "$PATH_CONFIG" "$PATH_DATA"; do
	    if [ ! -e "$dir" ]; then
	        mkdir --parents "$dir"
	    fi
	done
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
	init_userdir_files "$PATH_CONFIG" "$CONFIG_FILES"
	init_userdir_files "$PATH_DATA" "$DATA_FILES"
	init_prefix_files "$PATH_CONFIG" "$CONFIG_FILES"
	init_prefix_files "$PATH_DATA" "$DATA_FILES"
	init_prefix_dirs "$PATH_CONFIG" "$CONFIG_DIRS"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"

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
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# WINE - write launcher script for winecfg
# USAGE: launcher_write_script_wine_winecfg $application
# NEEDED VARS: GAME_ID
# CALLED BY: launcher_write_script_wine_winecfg
launcher_write_script_wine_winecfg() {
	local application
	application="$1"
	# shellcheck disable=SC2034
	APP_WINECFG_ID="${GAME_ID}_winecfg"
	# shellcheck disable=SC2034
	APP_WINECFG_TYPE='wine'
	# shellcheck disable=SC2034
	APP_WINECFG_EXE='winecfg'
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
	wine "$APP_EXE" $APP_OPTIONS $@

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

