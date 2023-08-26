# Returns a list of directories to scan for game scripts
# USAGE: games_list_sources
# RETURNS: A list of directories, separated by line breaks
games_list_sources() {
	# Include the current user game scripts collections
	local user_collections_basedir
	user_collections_basedir="${XDG_DATA_HOME:=$HOME/.local/share}/play.it/games"
	if [ -d "$user_collections_basedir" ]; then
		find "$user_collections_basedir" -mindepth 1 -maxdepth 1 -type d | sort
	fi

	# Include the system-provided game scripts collections
	local system_prefix system_collections_basedir
	for system_prefix in \
		'/usr/local/share/games' \
		'/usr/local/share' \
		'/usr/share/games' \
		'/usr/share'
	do
		system_collections_basedir="${system_prefix}/play.it/games"
		if [ -d "$system_collections_basedir" ]; then
			find "$system_collections_basedir" -mindepth 1 -maxdepth 1 -type d | sort
		fi
	done
}

# List all available game scripts
# USAGE: games_list_scripts_all
# RETURN: a list of available game scripts,
#         separated by line breaks
games_list_scripts_all() {
	local games_sources
	games_sources=$(games_list_sources)

	# Return early if no game script could be found
	if [ -z "$games_sources" ]; then
		return 0
	fi

	while read -r games_collection; do
		find "$games_collection" -name play-\*.sh | sort
	done <<- EOF
	$(printf '%s' "$games_sources")
	EOF
}

# List the game scripts providing support for the given archive name
# USAGE: games_find_scripts_for_archive $archive_name
# RETURN: a list of game scripts,
#         separated by line breaks
games_find_scripts_for_archive() {
	local archive_name
	archive_name="$1"

	## xargs return code is ignored,
	## to prevent a failure state if no available script has support for the given archive.
	set +o errexit
	games_list_scripts_all | xargs grep \
		--files-with-matches \
		--regexp="^ARCHIVE_[0-9A-Z_]\\+=['\"]${archive_name}['\"]"
	set -o errexit
}

# Print the path to the first game script with support with the given archive name
# USAGE: games_find_script_for_archive $archive_name
# RETURN: the path to a single game script
games_find_script_for_archive() {
	local archive_name
	archive_name="$1"

	local scripts_list
	scripts_list=$(games_find_scripts_for_archive "$archive_name")
	printf '%s' "$scripts_list" | head --lines=1
}

