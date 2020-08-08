#!/usr/bin/env sh
set -o errexit

file='play.it-2/lib/libplayit2.sh'
shell='sh'
printf 'Testing %s validity using ShellCheck in %s mode…\n' "$file" "$shell"
shellcheck --shell="$shell" --exclude=SC2016,SC2039,SC2059,SC2086 "$file"

exit 0
