# List the games supported by the current script
# USAGE: games_list_supported
# RETURN: a list of games,
#         separated by line breaks,
#         using the following format for each line:
#         game-id | Game name
games_list_supported() {
	local archives_list
	archives_list=$(archives_return_list)

	local ARCHIVE game_id game_name
	for ARCHIVE in $archives_list; do
		game_id=$(game_id)
		game_name=$(game_name)
		printf '%s | %s\n' "$game_id" "$game_name"
	done | sort --unique
}

# List all games supported by the available scripts
# USAGE: games_list_supported_all
# RETURN: a list of games,
#         separated by line breaks,
#         using the following format for each line:
#         game-id | Game name
games_list_supported_all() {
	local scripts_list
	scripts_list=$(games_list_scripts_all)

	local available_threads
	available_threads=$(nproc)
	## Passing the --list-supported-games switch is not required,
	## because $PLAYIT_OPTION_LIST_SUPPORTED_GAMES is already set.
	printf '%s' "$scripts_list" | \
		xargs --delimiter='\n' --max-args=1 --max-procs="$available_threads" sh | \
		sort --unique
}

