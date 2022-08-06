# get cached md5sum identified by a name
# USAGE: archive_get_md5sum_cached $name
archive_get_md5sum_cached() {
	local name
	name="$1"
	assert_not_empty 'name' 'archive_get_md5sum_cached'

	get_value "${name}_CACHED_MD5SUM"
}

# compute md5sum for a given file, store it in a cached variable
# USAGE: archive_get_md5sum_computed $name $file
archive_get_md5sum_computed() {
	local name file
	name="$1"
	file="$2"
	assert_not_empty 'name' 'archive_get_md5sum_computed'
	assert_not_empty 'file' 'archive_get_md5sum_computed'
	if [ ! -f "$file" ]; then
		error_not_a_file "$file"
		return 1
	fi

	if ! command -v 'md5sum' 'awk' >/dev/null 2>&1; then
		error_unavailable_command 'archive_get_md5sum_computed' 'md5sum'
		return 1
	fi

	local md5sum
	md5sum=$(md5sum "$file" | awk '{print $1}')
	export "${name?}_CACHED_MD5SUM=$md5sum"
}

# check if there is a cached md5sum value for the given name
# USAGE: archive_has_md5sum_cached $name
archive_has_md5sum_cached() {
	local name
	name="$1"
	assert_not_empty 'name' 'archive_has_md5sum_cached'

	test -n "$(archive_get_md5sum_cached "$name")"
}

# check integrity of target file against MD5 control sum
# USAGE: archive_integrity_check_md5 $archive $file ($name)
archive_integrity_check_md5() {
	local archive file name
	archive="$1"
	file="$2"
	name="$3"
	assert_not_empty 'archive' 'archive_integrity_check_md5'
	assert_not_empty 'file' 'archive_integrity_check_md5'
	assert_not_empty 'name' 'archive_integrity_check_md5'
	if [ ! -f "$file" ]; then
		error_not_a_file "$file"
		return 1
	fi

	# Cache MD5 hash here to prevent it from getting ignored in a subshell
	if ! archive_has_md5sum_cached "$name"; then
		info_archive_hash_computation "$file"
		archive_get_md5sum_computed "$name" "$file"
		info_archive_hash_computation_done
	fi

	local archive_sum file_sum
	archive_sum="$(get_value "${archive}_MD5")"
	file_sum="$(archive_get_md5sum_cached "$name")"
	if [ "$file_sum" != "$archive_sum" ]; then
		error_hashsum_mismatch "$file"
		return 1
	fi
}

