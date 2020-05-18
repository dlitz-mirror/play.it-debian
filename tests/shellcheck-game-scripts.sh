#!/usr/bin/env sh
set -o errexit

while getopts "s:" opt; do
    case "$opt" in
    s)  shell=$OPTARG
        ;;
    esac
done

count="$(find 'play.it-2/games' -type f | wc --lines)"
max_procs="$(nproc)"
max_args="$((count / max_procs + 1))"
printf 'Testing game scripts validity using ShellCheck in %s mode…\n' "$shell"
find 'play.it-2/games' -type f | xargs --max-args="$max_args" --max-procs="$max_procs" shellcheck --exclude=SC2034 --external-sources --shell="$shell"

exit 0
