# print the id of the current game
# USAGE: game_id
# RETURN: the game id, limited to the characters set [-_0-9a-z]
#         the id can not start nor end with a character from the set [-_]
game_id() {
	# The game id might might be archive-specific
	local game_id
	game_id=$(get_context_specific_value 'archive' 'GAME_ID')

	# Check that the id fits the format restrictions
	if ! printf '%s' "$game_id" | \
		grep --quiet --regexp='^[0-9a-z][-_0-9a-z]\+[0-9a-z]$'
	then
		error_game_id_invalid "$game_id"
		return 1
	fi

	printf '%s' "$game_id"
}

