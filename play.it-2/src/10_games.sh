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

