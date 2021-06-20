# Returns a list of directories to scan for game scripts
# USAGE: games_list_sources
# RETURNS: A list of directories, separated by line breaks
games_list_sources() {
	# If the "play.it" command has been called from a local git repository,
	# includes its shipped game scripts collection
	# shellcheck disable=SC2039
	local shipped_collection
	shipped_collection="$(dirname "$0")/play.it-2/games"
	if [ -d "$shipped_collection" ]; then
		printf '%s\n' "$shipped_collection"
	fi

	# Include the current user game scripts collections
	# shellcheck disable=SC2039
	local user_collections_basedir
	user_collections_basedir="${XDG_DATA_HOME:=$HOME/.local/share}/play.it/games"
	if [ -d "$user_collections_basedir" ]; then
		find "$user_collections_basedir" -mindepth 1 -maxdepth 1 -type d | sort
	fi

	# Include the system-provided game scripts collections
	# shellcheck disable=SC2039
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

	return 0
}

# Return a list of game scripts providing support for the given archive name
# USAGE: games_find_scripts_for_archive $archive_name
# RETURNS: A list of game scripts, separated by line breaks
games_find_scripts_for_archive() {
	# shellcheck disable=SC2039
	local archive_name
	archive_name="$1"

	# shellcheck disable=SC2039
	local regexp
	regexp="^ARCHIVE_[0-9A-Z_]\\+=['\"]${archive_name}['\"]"
	while read -r games_collection; do
		find "$games_collection" -name play-\*.sh -exec \
			grep --files-with-matches --regexp="$regexp" {} + | sort
	done <<- EOF
	$(games_list_sources)
	EOF

	return 0
}

# Returns the first game script with support with the given archive name
# USAGE: games_find_script_for_archive $archive_name
# RETURNS: A single game script
games_find_script_for_archive() {
	# shellcheck disable=SC2039
	local archive_name
	archive_name="$1"

	games_find_scripts_for_archive "$archive_name" | head --lines=1

	return 0
}

