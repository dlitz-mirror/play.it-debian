#!/bin/sh
set -o errexit

TESTED_SCRIPT='play.it'
SHELLCHECK_OPTIONS='--external-sources --shell=sh'

printf 'Testing %s validity using ShellCheck…\n' "$TESTED_SCRIPT"
shellcheck $SHELLCHECK_OPTIONS "$TESTED_SCRIPT"

exit 0
