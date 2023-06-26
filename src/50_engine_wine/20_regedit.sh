# WINE launcher - Set environment for registry keys persistent storage
# USAGE: wine_launcher_regedit_environment
wine_launcher_regedit_environment() {
	# Return early if no persistent registry keys are listed
	if [ -z "${WINE_REGEDIT_PERSISTENT_KEYS:-}" ]; then
		return 0
	fi

	cat <<- 'EOF'
	# Set environment for registry keys persistent storage

	USER_PERSISTENT_PATH_REGEDIT="${USER_PERSISTENT_PATH}/wine/regedit"
	REGEDIT_DUMPS_WINEPREFIX_PATH="${WINEPREFIX}/drive_c/${GAME_ID}/wine/regedit"
	EOF
	cat <<- EOF
	REGEDIT_PERSISTENT_KEYS='$WINE_REGEDIT_PERSISTENT_KEYS'

	EOF
	{
		cat <<- 'EOF'
		## Convert registry key name to file path
		regedit_convert_key_to_path() {
		    printf '%s.reg' "$1" | \
		        sed 's#\\#/#g' | \
		        tr '[:upper:]' '[:lower:]'
		}

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# WINE launcher - Load registry keys during prefix initialization
# USAGE: regedit_initial
regedit_initial() {
	# Return early if there is no key to load during prefix initilization
	if [ -z "${APP_REGEDIT:-}" ]; then
		return 0
	fi

	{
		cat <<- EOF
		    ## Load registry scripts
		    registry_scripts='$APP_REGEDIT'
		EOF
		cat <<- 'EOF'
		    for registry_script in $registry_scripts; do
		        (
		            cd "${WINEPREFIX}/drive_c/${GAME_ID}"
		            printf 'Loading registry script: %s\n' "$registry_script"
		            $(regedit_command) "$registry_script"
		        )
		    done

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# WINE launcher - Store registry keys in a persistent path
# USAGE: wine_launcher_regedit_store
wine_launcher_regedit_store() {
	# Return early if no persistent registry keys are listed
	if [ -z "${WINE_REGEDIT_PERSISTENT_KEYS:-}" ]; then
		return 0
	fi

	{
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
		done << EOL
		$(printf '%s' "$REGEDIT_PERSISTENT_KEYS")
		EOL
		mkdir --parents "$USER_PERSISTENT_PATH_REGEDIT"
		(
		    cd "$REGEDIT_DUMPS_WINEPREFIX_PATH"
		    find . -type f \
		        -exec cp --force --parents --target-directory="$USER_PERSISTENT_PATH_REGEDIT" {} +
		)

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# WINE launcher - Load registry keys from persistent dumps
# USAGE: wine_launcher_regedit_load
wine_launcher_regedit_load() {
	# Return early if no persistent registry keys are listed
	if [ -z "${WINE_REGEDIT_PERSISTENT_KEYS:-}" ]; then
		return 0
	fi

	{
		cat <<- 'EOF'
		# Load registry keys from persistent dumps

		if [ -e "$USER_PERSISTENT_PATH_REGEDIT" ]; then
		    mkdir --parents "$REGEDIT_DUMPS_WINEPREFIX_PATH"
		    (
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
		done << EOL
		$(printf '%s' "$REGEDIT_PERSISTENT_KEYS")
		EOL

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}
