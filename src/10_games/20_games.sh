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

	local script
	for script in $scripts_list; do
		$script --list-supported-games
	done | sort --unique
}

