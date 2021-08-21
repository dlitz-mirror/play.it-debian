#!/bin/sh
set -o errexit

TESTED_SCRIPT='play.it-2/lib/libplayit2.sh'
SHELLCHECK_OPTIONS='--shell=sh'

# Exclude warning SC2016:
# Expressions don't expand in single quotes, use double quotes for that.
# cf. https://github.com/koalaman/shellcheck/wiki/SC2016
SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC2016"

# Exclude warning SC2059:
# Don't use variables in the printf format string. Use printf "..%s.." "$foo".
# cf. https://github.com/koalaman/shellcheck/wiki/SC2059
SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC2059"

# Exclude warning SC2086:
# Double quote to prevent globbing and word splitting.
# cf. https://github.com/koalaman/shellcheck/wiki/SC2086
SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC2086"

# Only ShellCheck ≥ 0.7.2 has support for rule SC3043
SHELLCHECK_VERSION=$(LANG=C shellcheck --version | sed --silent 's/^version: \([0-9].\+\)$/\1/p')
LOCAL_EXCLUSION='SC3043'
if [ "$(printf '%s' "$SHELLCHECK_VERSION" | cut --delimiter='.' --fields=1)" -lt 1 ]; then
	if \
		[ "$(printf '%s' "$SHELLCHECK_VERSION" | cut --delimiter='.' --fields=2)" -lt 7 ] \
		|| [ "$(printf '%s' "$SHELLCHECK_VERSION" | cut --delimiter='.' --fields=2)" -eq 7 ] \
		&& [ "$(printf '%s' "$SHELLCHECK_VERSION" | cut --delimiter='.' --fields=3)" -lt 2 ]
	then
		LOCAL_EXCLUSION='SC2039'
	fi
fi
case "$LOCAL_EXCLUSION" in
	('SC3043')
		# Exclude warning SC3043:
		# In POSIX sh, local is undefined.
		# cf. https://github.com/koalaman/shellcheck/wiki/SC3043
		SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC3043"
	;;
	('SC2039')
		# Exclude warning SC2039:
		# In POSIX sh, something is undefined.
		# cf. https://github.com/koalaman/shellcheck/wiki/SC2039
		SHELLCHECK_OPTIONS="${SHELLCHECK_OPTIONS} --exclude=SC2039"
	;;
esac

printf 'Testing %s validity using ShellCheck…\n' "$TESTED_SCRIPT"
shellcheck $SHELLCHECK_OPTIONS "$TESTED_SCRIPT"

exit 0
