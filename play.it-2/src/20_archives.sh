# set up a required archive
# USAGE: archive_initialize_required $archive_name $archive_candidate[…]
# RETURNS: nothing
archive_initialize_required() {
	local archive_name archive_candidate
	archive_name="$1"
	shift 1

	archive_candidate=$(archive_find_from_candidates "$archive_name" "$@")

	# Throw an error if no archive candidate has been found
	if [ -z "$archive_candidate" ]; then
		error_archive_not_found "$@"
	fi

	# Call common part of archive initialization
	archive_initialize "$archive_name" "$archive_candidate"
	return 0
}

# set up an optional archive
# USAGE: archive_initialize_optional $archive_name $archive_candidate[…]
# RETURNS: nothing
archive_initialize_optional() {
	local archive_name archive_candidate
	archive_name="$1"
	shift 1

	archive_candidate=$(archive_find_from_candidates "$archive_name" "$@")

	# Return early if no archive candidate has been found
	if [ -z "$archive_candidate" ]; then
		return 0
	fi

	# Call common part of archive initialization
	archive_initialize "$archive_name" "$archive_candidate"
	return 0
}

# common part of an archive initialization
# USAGE: archive_initialize $archive_name $archive_candidate
# RETURNS: nothing
archive_initialize() {
	local archive_name archive_candidate archive_path archive_part_name archive_part_candidate
	archive_name="$1"
	archive_candidate="$2"

	archive_path=$(archive_find_path "$archive_candidate")

	###
	# TODO
	# Check that the archive path is not empty
	###

	# Set the current archive properties from the candidate one
	archive_set_properties_from_candidate "$archive_name" "$archive_candidate"

	# Check archive integrity if it comes with a MD5 hash
	if [ -n "$(get_value "${archive_name}_MD5")" ]; then
		archive_integrity_check "$archive_candidate" "$archive_path" "$archive_name"
	fi

	# Check dependencies
	check_deps

	# Update total size of all archives
	archive_add_size_to_total "$archive_name"

	# Check for archive extra parts
	for i in $(seq 1 9); do
		archive_part_name="${archive_name}_PART${i}"
		archive_part_candidate="${archive_candidate}_PART${i}"
		test -z "$(get_value "$archive_part_candidate")" && break
		archive_initialize_required "$archive_part_name" "$archive_part_candidate"
	done

	return 0
}

# find a single archive from a list of candidates
# USAGE: archive_find_from_candidates $archive_name $archive_candidate[…]
# RETURNS: an archive identifier, or nothing
archive_find_from_candidates() {
	local archive_name archive_candidate file_name file_path current_archive_path
	archive_name="$1"
	shift 1

	# An archive path might already be set, if it has been passed on the command line
	if [ -n "$(get_value $archive_name)" ]; then
		current_archive_path="$(get_value $archive_name)"
	fi

	# Loop around archive candidates, stopping on the first one found
	for archive_candidate in "$@"; do
		if [ -n "$current_archive_path" ]; then
			file_name=$(get_value "$archive_candidate")
			if [ "$(basename "$current_archive_path")" = "$file_name" ]; then
				file_path=$(realpath "$current_archive_path")
			fi

		else
			file_path=$(archive_find_path "$archive_candidate")
		fi
		test -n "$file_path" && break
	done

	# Return early if no archive candidate has been found
	if [ -z "$file_path" ]; then
		return 0
	fi

	# Return the identifier of the found archive candidate
	printf '%s' "$archive_candidate"
	return 0
}

# return the absolute path to a given archive
# USAGE: archive_find_path $archive_name
# RETURNS: an absolute file path, or nothing
archive_find_path() {
	local archive_name archive_filename archive_path
	archive_name="$1"

	# Right now, an archive can only be found using its file name
	archive_filename=$(get_value "$archive_name")
	archive_path=$(archive_find_path_from_name "$archive_filename")

	printf '%s' "$archive_path"
	return 0
}

# find an archive from its file name
# USAGE: archive_find_path_from_name $file_name
# RETURNS: an absolute file path, or nothing
archive_find_path_from_name() {
	local file_name
	file_name="$1"

	###
	# TODO
	# Check that the provided file name is not empty
	###

	# Look for the archive in current directory
	if [ -f "$PWD/$file_name" ]; then
		file_path=$(realpath "$PWD/$file_name")
		printf '%s' "$file_name"
		return 0
	fi

	# Look for the archive in the same directory than the main archive
	if \
		[ -n "$SOURCE_ARCHIVE" ] && \
		[ -f "$(dirname "$SOURCE_ARCHIVE")/$file_name" ]
	then
		file_path=$(realpath "$(dirname "$SOURCE_ARCHIVE")/$file_name")
		printf '%s' "$file_path"
		return 0
	fi

	# No archive found, return nothing
	return 0
}

# set an archive properties from a candidate informations
# USAGE: archive_set_properties_from_candidate $archive_name $archive_candidate
# RETURNS: nothing
archive_set_properties_from_candidate() {
	local archive_name archive_candidate archive_path property
	archive_name="$1"
	archive_candidate="$2"

	###
	# TODO
	# Check that the provided archive name is not empty
	###

	###
	# TODO
	# Check that the provided archive candidate is not empty
	###

	# Set archive path
	archive_path=$(archive_find_path "$archive_candidate")

	###
	# TODO
	# Check that the archive path is not empty
	###

	export "${archive_name}=$archive_path"

	# Print information message
	information_file_in_use "$archive_path"

	# Set list of extra archive parts
	for i in $(seq 1 9); do
		export "${archive_name}_PART${i}=$(get_value "${archive_candidate}_PART${i}")"
	done

	# Set other archive properties
	for property in \
		'MD5' \
		'TYPE' \
		'SIZE' \
		'VERSION'
	do
		export "${archive_name}_${property}=$(get_value "${archive_candidate}_${property}")"
	done

	return 0
}

# add the size of given archive to the total size of all archives in use
# USAGE: archive_add_size_to_total $archive
# RETURNS: nothing
archive_add_size_to_total() {
	local archive archive_size
	archive="$1"

	###
	# TODO
	# Check that the provided archive name is not empty
	###

	# Get the given archive size, defaults to a size of 0
	archive_size=$(get_value "${archive}_SIZE")
	: "${archive_size:=0}"

	# Update the total size of all archives in use
	: "${ARCHIVE_SIZE:=0}"
	ARCHIVE_SIZE=$((ARCHIVE_SIZE + archive_size))
	export ARCHIVE_SIZE

	return 0
}

# get the type of a given archive
# USAGE: archive_get_type $archive_name
# RETURNS: an archive type
archive_get_type() {
	local archive_name archive_file archive_type
	archive="$1"

	###
	# TODO
	# Check that the provided archive name is not empty
	###

	# Return archive type early if it is already set
	archive_type=$(get_value "${archive}_TYPE")
	if [ -n "$archive_type" ]; then
		printf '%s' "$archive_type"
		return 0
	fi

	# Guess archive type from its file name
	archive_file=$(get_value "$archive")
	case "$archive_file" in
		(*'.cab')
			archive_type='cabinet'
		;;
		(*'.deb')
			archive_type='debian'
		;;
		('setup_'*'.exe'|'patch_'*'.exe')
			archive_type='innosetup'
		;;
		('gog_'*'.sh')
			archive_type='mojosetup'
		;;
		(*'.iso')
			archive_type='iso'
		;;
		(*'.msi')
			archive_type='msi'
		;;
		(*'.rar')
			archive_type='rar'
		;;
		(*'.tar')
			archive_type='tar'
		;;
		(*'.tar.gz'|*'.tgz')
			archive_type='tar.gz'
		;;
		(*'.zip')
			archive_type='zip'
		;;
		(*'.7z')
			archive_type='7z'
		;;
		(*)
			error_archive_type_not_set "$archive_name"
		;;
	esac

	# Return guessed type
	printf '%s' "$archive_type"
	return 0
}

# check integrity of target file
# USAGE: archive_integrity_check $archive $file ($name)
# CALLS: archive_integrity_check_md5
archive_integrity_check() {
	local archive
	local file
	local name
	archive="$1"
	file="$2"
	name="$3"
	case "$OPTION_CHECKSUM" in
		('md5')
			archive_integrity_check_md5 "$archive" "$file" "$name"
		;;
		('none')
			return 0
		;;
		(*)
			error_invalid_argument 'OPTION_CHECKSUM' 'archive_integrity_check'
		;;
	esac
}

# return the list of supported archives for the current script
# USAGE: archives_return_list
# RETURNS: the list of identifiers of the supported archives,
#          as a list of strings separated by spaces or line breaks
archives_return_list() {
	# If a list is already explicitely set, return early
	if [ -n "$ARCHIVES_LIST" ]; then
		printf '%s' "$ARCHIVES_LIST"
		return 0
	fi

	# Parse the calling script to guess the identifiers of the archives it supports
	# shellcheck disable=SC2039
	local script pattern
	script="$0"
	pattern='^ARCHIVE_[0-9A-Z]\+\(_OLD[0-9A-Z]*\)*='
	grep --regexp="$pattern" "$script" | \
		cut --delimiter='=' --fields=1

	return 0
}

