#!/bin/sh
set -o errexit

script="$1"

if [ ! -e "$script" ]; then
	printf 'USAGE: %s SCRIPT\n' "$0"
	exit 0
fi

if grep '^ARCHIVES_LIST' "$script" >/dev/null 2>&1; then
	archives_list=$(grep '^ARCHIVES_LIST' "$script" | sed "s/ARCHIVES_LIST='\\(.*\\)'/\\1/")
else
	while read -r archive; do
		if [ -z "$archives_list" ]; then
			archives_list="$archive"
		else
			archives_list="$archives_list $archive"
		fi
	done <<- EOL
	$(grep\
		--regexp='^ARCHIVE_[^_]\+='\
		--regexp='^ARCHIVE_[^_]\+_OLD='\
		--regexp='^ARCHIVE_[^_]\+_OLD[^_]\+='\
		"$script" | sed 's/\([^=]\)=.\+/\1/'\
	)
	EOL
fi

tmp_directory=$(mktemp --directory --tmpdir="${TMPDIR:-/tmp}" 'play.it.XXXXX')

for archive_name in $archives_list; do
	archive=$(grep "^$archive_name=" "$script" | sed "s/$archive_name='\\(.*\\)'/\\1/")
	touch "$tmp_directory/$archive"
	for i in $(seq 1 9); do
		archive_extra_part_name="${archive_name}_PART${i}"
		if grep "^$archive_extra_part_name=" "$script" >/dev/null 2>&1; then
			archive_extra_part=$(grep "^$archive_extra_part_name=" "$script" | sed "s/$archive_extra_part_name='\\(.*\\)'/\\1/")
			touch "$tmp_directory/$archive_extra_part"
		else
			break
		fi
	done
	"$script" "$tmp_directory/$archive" --checksum=none --skip-free-space-check --dry-run
	rm "$tmp_directory/$archive"
	for i in $(seq 1 9); do
		archive_extra_part_name="${archive_name}_PART${i}"
		if grep "^$archive_extra_part_name=" "$script" >/dev/null 2>&1; then
			archive_extra_part=$(grep "^$archive_extra_part_name=" "$script" | sed "s/$archive_extra_part_name='\\(.*\\)'/\\1/")
			rm "$tmp_directory/$archive_extra_part"
		else
			break
		fi
	done
done

rmdir "$tmp_directory"

exit 0
