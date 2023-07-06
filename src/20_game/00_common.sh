# print the id of the current game
# USAGE: game_id
# RETURN: the game id, limited to the characters set [-0-9a-z],
#         the id can not start nor end with an hyphen (-) character
game_id() {
	# The game id might might be archive-specific
	local game_id
	game_id=$(context_value 'GAME_ID')

	# Check that the id fits the format restrictions
	if ! game_id_validity_check "$game_id"; then
		error_game_id_invalid "$game_id"
		return 1
	fi

	printf '%s' "$game_id"
}

# Print the id of the current expansion
# USAGE: expansion_id
# RETURN: the expansion id, limited to the characters set [-0-9a-z],
#         the id can not start nor end with an hyphen (-) character,
#         an empty value is returned if no expansion id is set
expansion_id() {
	# The expansion id might might be archive-specific
	local expansion_id
	expansion_id=$(context_value 'EXPANSION_ID')

	# Return early if no expansion id is set.
	if [ -z "$expansion_id" ]; then
		return 0
	fi

	# Check that the id fits the format restrictions
	if ! game_id_validity_check "$expansion_id"; then
		error_expansion_id_invalid "$expansion_id"
		return 1
	fi

	printf '%s' "$expansion_id"
}

# Check the validity of the given game (or expansion) id
# USAGE: game_id_validity_check $id_string
# RETURN: 0 if the id is valid, 1 if it is not
game_id_validity_check() {
	local game_id
	game_id="$1"

	# Check that the given id:
	# - is limited to the characters set [-0-9a-z]
	# - does not start with an hyphen (-) character
	# - does not end with an hyphen (-) character
	printf '%s' "$game_id" | \
		grep --quiet --regexp='^[0-9a-z][-0-9a-z]\+[0-9a-z]$'
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
