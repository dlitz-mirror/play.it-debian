#!/usr/bin/env sh
set -o errexit

script="$1"

if [ ! -e "$script" ]; then
	printf 'USAGE: %s SCRIPT\n' "$0"
	exit 0
fi

for shell in 'sh' 'bash' 'dash' 'ksh'; do
	printf 'Testing %s validity using ShellCheck in %s mode…\n' "$script"  "$shell"
	shellcheck --exclude=SC2034 --external-sources --shell="$shell" "$script"
done

exit 0
