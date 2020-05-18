#!/usr/bin/env sh
set -o errexit

status=0
while read -r script; do
	name=$(basename "$script" | sed 's/play-\(.*\)\.sh/\1/')
	if ! grep --quiet --regexp="^shellcheck-game-${name}:$" '.gitlab-ci.yml'; then
		printf 'Error:\n'
		printf '%s is not covered by ShellCheck tests.\n' "$script"
		status=1
	fi
done << EOL
$(find 'play.it-2/games' -type f)
EOL

exit $status
