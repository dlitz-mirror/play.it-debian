#!/usr/bin/env sh
set -o errexit

file='play.it'
for shell in 'sh' 'bash' 'dash' 'ksh'; do
	printf 'Testing %s validity using ShellCheck in %s mode…\n' "$file" "$shell"
	shellcheck --external-sources --shell="$shell" "$file"
done

exit 0
