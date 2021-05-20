#!/bin/sh
set -o errexit

TESTED_SCRIPT="$1"
SHELLCHECK_OPTIONS='--external-sources --shell=sh'

# Exclude warning SC2016:
# Expressions don't expand in single quotes, use double quotes for that.
# cf. https://github.com/koalaman/shellcheck/wiki/SC2016
SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC2016"

# Exclude warning SC2031:
# var was modified in a subshell. That change might be lost.
# cf. https://github.com/koalaman/shellcheck/wiki/SC2031
SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC2031"

# Exclude warning SC2034:
# foo appears unused. Verify it or export it.
# cf. https://github.com/koalaman/shellcheck/wiki/SC2034
SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC2034"

# Exclude warning SC2059:
# Don't use variables in the printf format string. Use printf "..%s.." "$foo".
# cf. https://github.com/koalaman/shellcheck/wiki/SC2059
SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC2059"

printf 'Testing %s validity using ShellCheck…\n' "$TESTED_SCRIPT"
shellcheck $SHELLCHECK_OPTIONS "$TESTED_SCRIPT"

exit 0
