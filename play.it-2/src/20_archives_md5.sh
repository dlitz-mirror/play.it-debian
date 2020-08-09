# get cached md5sum identified by a name
# USAGE: archive_get_md5sum_cached $name
# CALLS: error_empty_string
archive_get_md5sum_cached() {
	local name md5sum
	name="$1"
	if [ -z "$name" ]; then
		error_empty_string 'archive_get_md5sum_cached' 'name'
	fi
	get_value "${name}_CACHED_MD5SUM"
}

# compute md5sum for a given file, store it in a cached variable
# USAGE: archive_get_md5sum_computed $name $file
# CALLS: error_empty_string error_not_a_file error_unavailable_command
archive_get_md5sum_computed() {
	local name file md5sum
	name="$1"
	file="$2"
	if [ -z "$name" ]; then
		error_empty_string 'archive_get_md5sum_computed' 'name'
	fi
	if [ -z "$file" ]; then
		error_empty_string 'archive_get_md5sum_computed' 'file'
	fi
	if [ ! -f "$file" ]; then
		error_not_a_file "$file"
	fi
	if ! command -v 'md5sum' 'awk' >/dev/null 2>&1; then
		error_unavailable_command 'archive_get_md5sum_computed' 'md5sum'
	fi
	md5sum=$(md5sum "$file" | awk '{print $1}')
	export "${name?}_CACHED_MD5SUM=$md5sum"
}

# check if there is a cached md5sum value for the given name
# USAGE: archive_has_md5sum_cached $name
# CALLS: archive_get_md5sum_cached
archive_has_md5sum_cached() {
	local name
	name="$1"
	if [ -z "$name" ]; then
		error_empty_string 'archive_has_md5sum_cached' 'name'
	fi
	test -n "$(archive_get_md5sum_cached "$name")"
}

# check integrity of target file against MD5 control sum
# USAGE: archive_integrity_check_md5 $archive $file ($name)
# CALLS: info_archive_integrity_check error_hashsum_mismatch
# CALLED BY: archive_integrity_check
archive_integrity_check_md5() {
	local archive file name
	archive="$1"
	file="$2"
	name="$3"
	if [ -z "$archive" ]; then
		error_empty_string 'archive_integrity_check_md5' 'archive'
	fi
	if [ -z "$file" ]; then
		error_empty_string 'archive_integrity_check_md5' 'file'
	fi
	if [ -z "$name" ]; then
		error_empty_string 'archive_integrity_check_md5' 'name'
	fi
	if [ ! -f "$file" ]; then
		error_not_a_file "$file"
	fi
	# Cache MD5 hash here to prevent it from getting ignored in a subshell
	if ! archive_has_md5sum_cached "$name"; then
		info_archive_hash_computation "$file"
		archive_get_md5sum_computed "$name" "$file"
		print_ok
	fi
	archive_sum="$(get_value "${ARCHIVE}_MD5")"
	file_sum="$(archive_get_md5sum_cached "$name")"
	info_archive_integrity_check "$file"
	if [ "$file_sum" != "$archive_sum" ]; then
		error_hashsum_mismatch "$file"
	fi
	print_ok
}

