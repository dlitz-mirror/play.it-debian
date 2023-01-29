# print the id of the current game
# USAGE: game_id
# RETURN: the game id, limited to the characters set [-_0-9a-z]
#         the id can not start nor end with a character from the set [-_]
game_id() {
	# The game id might might be archive-specific
	local game_id
	game_id=$(context_value 'GAME_ID')

	# Check that the id fits the format restrictions
	if ! printf '%s' "$game_id" | \
		grep --quiet --regexp='^[0-9a-z][-0-9a-z]\+[0-9a-z]$'
	then
		error_game_id_invalid "$game_id"
		return 1
	fi

	printf '%s' "$game_id"
}

# Print the display name of the current game
# If an expansion name is set, it is included
# USAGE: game_name
# RETURN: the game name, for use in package description and menu entries
game_name() {
	local game_name expansion_name
	game_name=$(context_value 'GAME_NAME')
	expansion_name=$(context_value 'EXPANSION_NAME')

	if [ -n "$expansion_name" ]; then
		printf '%s - %s' "$game_name" "$expansion_name"
	else
		printf '%s' "$game_name"
	fi
}
