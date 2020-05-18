#!/bin/sh
set -e

SRC_PATH="$(dirname "$0")/../src"

pattern='s/archive_extraction_innosetup_error_version() {/&\n\treturn 0/'
file="$SRC_PATH/30_archive-extraction.sh"
sed --in-place "$pattern" "$file"

case "${LANG%_*}" in
	('fr')
		string='Les scripts nʼémettront pas dʼerreur si innoextract renvoie un avertissement au sujet de la version dʼInnoSetup.'
	;;
	('en'|*)
		string='Scripts wonʼt fail if innoextract report an InnoSetup version warning.'
	;;
esac
printf '%s\n' "$string"

exit 0
