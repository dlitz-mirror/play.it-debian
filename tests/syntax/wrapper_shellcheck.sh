#!/usr/bin/env sh
set -o errexit

file='play.it'
shell='sh'
printf 'Testing %s validity using ShellCheck in %s mode…\n' "$file" "$shell"
shellcheck --external-sources --shell="$shell" "$file"

exit 0
