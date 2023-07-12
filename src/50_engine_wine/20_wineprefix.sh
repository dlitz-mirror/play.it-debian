# WINE launcher - Set the WINE prefix environment
# USAGE: wine_launcher_wineprefix_environment
wine_launcher_wineprefix_environment() {
	# Compute path to WINE prefix
	{
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
	} | sed --regexp-extended 's/( ){4}/\t/g'

	# Set compatibility links to legacy paths
	{
		cat <<- 'EOF'
		# Set compatibility link to a legacy user path
		wineprefix_legacy_link() {
		    path_current="$1"
		    path_legacy="$2"
		    user_directory="${WINEPREFIX}/drive_c/users/${USER}"
		    (
		        cd "$user_directory"
		        if [ ! -e "${user_directory}/${path_current}" ]; then
		            path_current_parent=$(dirname "$path_current")
		            mkdir --parents "$path_current_parent"
		            mv "$path_legacy" "$path_current"
		        fi
		        ln --symbolic "$path_current" "$path_legacy"
		    )
		}

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'

	# Compute WINE prefix architecture
	local package package_architecture wine_architecture
	package=$(context_package)
	package_architecture=$(package_architecture "$package")
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

# WINE launcher - Generate the WINE prefix
# USAGE: wine_launcher_wineprefix_generate
wine_launcher_wineprefix_generate() {
	{
		cat <<- 'EOF'
		# Generate the WINE prefix
		if ! [ -e "$WINEPREFIX" ]; then
		    mkdir --parents "$(dirname "$WINEPREFIX")"

		    ## Use LANG=C to avoid localized directory names
		    LANG=C $(wineboot_command) --init 2>/dev/null

		    ## Wait until the WINE prefix creation is complete
		    printf "Waiting for the WINE prefix initialization to complete, it might take a couple seconds…\\n"
		    while [ ! -f "${WINEPREFIX}/system.reg" ]; do
		        sleep 1s
		    done

		    ## Link game prefix into WINE prefix
		    ln --symbolic \
		        "$PATH_PREFIX" \
		        "${WINEPREFIX}/drive_c/${GAME_ID}"

		    ## Remove most links pointing outside of the WINE prefix
		    rm "$WINEPREFIX/dosdevices/z:"
		    find "$WINEPREFIX/drive_c/users/$(whoami)" -type l | while read -r directory; do
		        rm "$directory"
		        mkdir "$directory"
		    done

		    ## Set links to legacy paths
		    wineprefix_legacy_link 'AppData/Roaming' 'Application Data'
		    wineprefix_legacy_link 'Documents' 'My Documents'

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'

	# Run initial winetricks call
	local winetricks_verbs
	winetricks_verbs=$(wine_winetricks_verbs)
	if [ -n "$winetricks_verbs" ]; then
		{
			cat <<- EOF
			    ## Run initial winetricks call
			    winetricks_wrapper ${winetricks_verbs}

			EOF
		} | sed --regexp-extended 's/( ){4}/\t/g'
	fi

	# Load registry scripts
	regedit_initial

	# Set Direct3D renderer
	wine_launcher_renderer

	cat <<- 'EOF'
	fi

	EOF
}

# WINE launcher - Handle paths diversion from WINE prefix to persistent storage
# USAGE: wine_launcher_wineprefix_persistent
wine_launcher_wineprefix_persistent() {
	local persistent_directories
	persistent_directories=$(wine_persistent_directories)
	if [ -n "$persistent_directories" ]; then
		cat <<- EOF
		# Divert paths from the WINE prefix to persistent storage
		WINE_PERSISTENT_DIRECTORIES="$persistent_directories"
		EOF
		{
			cat <<- 'EOF'
			while read -r directory; do
			    if [ -z "$directory" ]; then
			        continue
			    fi
			    persistent_path_diversion "${WINEPREFIX}/drive_c" "${USER_PERSISTENT_PATH}/wineprefix" "$directory"
			done <<- EOL
			$(printf '%s' "$WINE_PERSISTENT_DIRECTORIES")
			EOL

			EOF
		} | sed --regexp-extended 's/( ){4}/\t/g'
		return 0
	fi

	# Handle diversions using the deprecated APP_WINE_LINK_DIRS variable
	if version_is_at_least '2.24' "$target_version"; then
		return 0
	fi
	if [ -n "${APP_WINE_LINK_DIRS:-}" ]; then
		wine_launcher_wineprefix_persistent_legacy
	fi
}
