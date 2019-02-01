#!/usr/bin/env sh
set -o errexit

make libplayit2.sh
file='play.it-2/lib/libplayit2.sh'
for shell in 'sh' 'bash' 'dash' 'ksh'; do
	printf 'Testing %s validity using ShellCheck in %s mode…\n' "$file" "$shell"
	shellcheck --shell="$shell" --exclude=SC2016,SC2039,SC2059,SC2086 "$file"
done

exit 0
