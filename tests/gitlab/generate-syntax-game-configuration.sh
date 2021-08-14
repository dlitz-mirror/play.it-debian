#!/bin/sh

TESTS_DIRECTORY=$(dirname "$0")
TEMPLATE_BASE="${TESTS_DIRECTORY}/syntax-game.base.yml"
TEMPLATE_OUTPUT="${TESTS_DIRECTORY}/syntax-game.yml"

modified_games() {
	# shellcheck disable=SC2039
	local commit
	for commit in $(git rev-list HEAD ^origin/master); do
		git diff --name-only "$commit^..$commit" -- 'play.it-2/games/play-*.sh'
	done | sort --unique
}

list_games() {
	# shellcheck disable=SC2039
	local script script_basename game_name
	# If modified games are listed, we are not on master
	# Check only the game scripts modified since last master update
	if [ "$(modified_games | wc --lines)" -gt 0 ]; then
		while read -r script; do
			[ -e "$script" ] || continue
			script_basename=$(basename "$script" .sh)
			game_name="${script_basename#play-}"
			printf '%s\n' "$game_name"
		done <<- EOF
		$(modified_games)
		EOF
	# If no modified game is listed, we are on master
	# Check all game scripts
	else
		for script in play.it-2/games/play-*.sh; do
			script_basename=$(basename "$script" .sh)
			game_name="${script_basename#play-}"
			printf '%s\n' "$game_name"
		done
	fi
}

generate_configuration() {
	# shellcheck disable=SC2039
	local game
	printf 'stages:\n'
	printf '  - syntax\n'
	printf '\n'
	while read -r game; do
		sed "s/\${game}/${game}/g" "$TEMPLATE_BASE"
	done <<- EOF
	$(list_games)
	EOF
}

generate_configuration > "$TEMPLATE_OUTPUT"

exit 0
