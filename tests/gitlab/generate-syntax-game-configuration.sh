#!/bin/sh

TESTS_DIRECTORY=$(dirname "$0")
ROOT_DIRECTORY="${TESTS_DIRECTORY}/../.."
GAMES_DIRECTORY="${ROOT_DIRECTORY}/play.it-2/games"
TEMPLATE_BASE="${TESTS_DIRECTORY}/syntax-game.base.yml"
TEMPLATE_OUTPUT="${TESTS_DIRECTORY}/syntax-game.yml"

list_games() {
	local script script_basename game_name
	for script in "$GAMES_DIRECTORY"/play-*.sh; do
		script_basename=$(basename $script .sh)
		game_name="${script_basename#play-}"
		printf '%s ' "$game_name"
	done
	return 0
}

generate_configuration() {
	local game
	printf 'stages:\n'
	printf '  - syntax\n'
	printf '\n'
	for game in $(list_games); do
		sed "s/\${game}/${game}/g" "$TEMPLATE_BASE"
	done
	return 0
}

generate_configuration > "$TEMPLATE_OUTPUT"

exit 0
