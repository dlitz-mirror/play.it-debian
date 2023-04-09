# set up a required archive
# USAGE: archive_initialize_required $archive_name $archive_candidate[…]
# RETURNS: nothing
archive_initialize_required() {
	local archive_name archive_candidate

	debug_entering_function 'archive_initialize_required'

	archive_name="$1"
	shift 1

	archive_candidate=$(archive_find_from_candidates "$archive_name" "$@")

	# Throw an error if no archive candidate has been found
	if [ -z "$archive_candidate" ]; then
		error_archive_not_found "$@"
		return 1
	fi

	# Call common part of archive initialization
	archive_initialize "$archive_name" "$archive_candidate"

	debug_leaving_function 'archive_initialize_required'

	return 0
}

# set up an optional archive
# USAGE: archive_initialize_optional $archive_name $archive_candidate[…]
# RETURNS: nothing
archive_initialize_optional() {
	local archive_name archive_candidate

	debug_entering_function 'archive_initialize_optional'

	archive_name="$1"
	shift 1

	archive_candidate=$(archive_find_from_candidates "$archive_name" "$@")

	# Return early if no archive candidate has been found
	if [ -z "$archive_candidate" ]; then
		return 0
	fi

	# Call common part of archive initialization
	archive_initialize "$archive_name" "$archive_candidate"

	debug_leaving_function 'archive_initialize_optional'

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
	assert_not_empty 'archive_path' 'archive_initialize'

	# Set the current archive properties from the candidate one
	archive_set_properties_from_candidate "$archive_name" "$archive_candidate"

	# Check archive integrity if it comes with a MD5 hash
	if ! variable_is_empty "${archive_name}_MD5"; then
		archive_integrity_check "$archive_candidate" "$archive_path" "$archive_name"
	fi

	# Check dependencies
	archive_dependencies_check "$archive_candidate"

	# Update total size of all archives
	archive_add_size_to_total "$archive_name"

	# Check for archive extra parts
	for i in $(seq 1 9); do
		archive_part_name="${archive_name}_PART${i}"
		archive_part_candidate="${archive_candidate}_PART${i}"
		# Stop looking at the first unset archive extra part.
		if variable_is_empty "$archive_part_candidate"; then
			break
		fi
		archive_initialize_required "$archive_part_name" "$archive_part_candidate"
	done

	return 0
}

# find a single archive from a list of candidates
# USAGE: archive_find_from_candidates $archive_name $archive_candidate[…]
# RETURNS: an archive identifier, or nothing
archive_find_from_candidates() {
	local archive_name
	archive_name="$1"
	shift 1

	# An archive path might already be set, if it has been passed on the command line
	local current_archive_path
	current_archive_path=$(get_value $archive_name)

	# Loop around archive candidates, stopping on the first one found
	local archive_candidate file_name file_path
	file_path=''
	for archive_candidate in "$@"; do
		if [ -n "$current_archive_path" ]; then
			file_name=$(get_value "$archive_candidate")
			if [ "$(basename "$current_archive_path")" = "$file_name" ]; then
				file_path=$(realpath "$current_archive_path")
			fi
		else
			file_path=$(archive_find_path "$archive_candidate")
		fi
		if [ -n "$file_path" ]; then
			break
		fi
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
# USAGE: archive_find_path $archive
# RETURNS: an absolute file path, or nothing
archive_find_path() {
	local archive
	archive="$1"

	local archive_name
	archive_name=$(get_value "$archive")

	archive_find_path_from_name "$archive_name"
}

# find an archive from its file name
# USAGE: archive_find_path_from_name $archive_name
# RETURNS: an absolute file path, or nothing
archive_find_path_from_name() {
	local archive_name
	archive_name="$1"

	# If the passed name starts with "/",
	# assume it is an absolute path to the archive file.
	if printf '%s' "$archive_name" | grep --quiet '^/'; then
		if [ -f "$archive_name" ]; then
			printf '%s' "$archive_name"
		fi
		# No archive found at the given absolute path,
		# return nothing.
		return 0
	fi

	# Look for the archive in current directory
	local archive_path
	archive_path="${PWD}/${archive_name}"
	if [ -f "$archive_path" ]; then
		realpath "$archive_path"
		return 0
	fi

	# Look for the archive in the same directory than the main archive
	if ! variable_is_empty 'SOURCE_ARCHIVE'; then
		local source_directory
		source_directory=$(dirname "$SOURCE_ARCHIVE")
		archive_path="${source_directory}/${archive_name}"
		if [ -f "$archive_path" ]; then
			realpath "$archive_path"
			return 0
		fi
	fi

	# No archive found, return nothing
	return 0
}

# set an archive properties from a candidate informations
# USAGE: archive_set_properties_from_candidate $archive_name $archive_candidate
# RETURNS: nothing
archive_set_properties_from_candidate() {
	local archive_name archive_candidate
	archive_name="$1"
	archive_candidate="$2"
	assert_not_empty 'archive_name' 'archive_set_properties_from_candidate'
	assert_not_empty 'archive_candidate' 'archive_set_properties_from_candidate'

	# Set archive path
	local archive_path
	archive_path=$(archive_find_path "$archive_candidate")
	assert_not_empty 'archive_path' 'archive_set_properties_from_candidate'

	export "${archive_name}=$archive_path"

	# Print information message
	information_file_in_use "$archive_path"

	# Set list of extra archive parts
	for i in $(seq 1 9); do
		# Stop looking at the first unset archive extra part.
		if variable_is_empty "${archive_candidate}_PART${i}"; then
			break
		fi
		export "${archive_name}_PART${i}=$(get_value "${archive_candidate}_PART${i}")"
	done

	# Set other archive properties
	local property
	for property in \
		'EXTRACTOR' \
		'EXTRACTOR_OPTIONS' \
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
	local archive
	archive="$1"
	assert_not_empty 'archive' 'archive_add_size_to_total'

	# Get the given archive size
	local archive_size
	archive_size=$(get_value "${archive}_SIZE")
	## Default to a size of 0
	if [ -z "$archive_size" ]; then
		archive_size='0'
	fi

	# Update the total size of all archives in use
	if variable_is_empty 'ARCHIVE_SIZE'; then
		ARCHIVE_SIZE='0'
	fi
	ARCHIVE_SIZE=$((ARCHIVE_SIZE + archive_size))
	export ARCHIVE_SIZE

	return 0
}

# get the type of a given archive
# USAGE: archive_get_type $archive_identifier
# RETURNS: an archive type
archive_get_type() {
	# Get the archive identifier, check that it is not empty
	local archive_identifier
	archive_identifier="$1"
	assert_not_empty 'archive_identifier' 'archive_get_type'

	# Return archive type early if it is already set
	local archive_type
	archive_type=$(get_value "${archive_identifier}_TYPE")
	if [ -n "$archive_type" ]; then
		printf '%s' "$archive_type"
		return 0
	fi

	# Guess archive type from its file name
	local archive_file
	archive_file=$(get_value "$archive_identifier")
	archive_type=$(archive_guess_type_from_name "$archive_file")
	if [ -n "$archive_type" ]; then
		printf '%s' "$archive_type"
		return 0
	fi

	# Guess archive type from its headers
	local archive_path
	archive_path=$(archive_find_path "$archive")
	archive_type=$(archive_guess_type_from_headers "$archive_path")
	if [ -n "$archive_type" ]; then
		printf '%s' "$archive_type"
		return 0
	fi

	# Fall back on using the type of the parent archive, if there is one
	if \
		printf '%s' "$archive_identifier" | \
		grep --quiet --word-regexp '^ARCHIVE_.*_PART[0-9]\+$'
	then
		local parent_archive
		parent_archive=$(printf '%s' "$archive_identifier" | sed 's/^\(ARCHIVE_.*\)_PART[0-9]\+$/\1/')
		archive_type=$(archive_get_type "$parent_archive")
		if [ -n "$archive_type" ]; then
			printf '%s' "$archive_type"
			return 0
		fi
	fi

	# Throw an error if no type could be found
	error_archive_type_not_set "$archive_identifier"
	return 1
}

# Guess the archive type from its file name
# USAGE: archive_guess_type_from_name $archive_file
# RETURNS: the archive type,
#          or an empty string is none could be guessed
archive_guess_type_from_name() {
	local archive_file
	archive_file="$1"

	local archive_type
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
		(*'.tar.bz2'|*'.tbz2')
			archive_type='tar.bz2'
		;;
		(*'.tar.gz'|*'.tgz')
			archive_type='tar.gz'
		;;
		(*'.tar.xz'|*'.txz')
			archive_type='tar.xz'
		;;
		(*'.zip')
			archive_type='zip'
		;;
		(*'.7z')
			archive_type='7z'
		;;
	esac

	printf '%s' "${archive_type:-}"
}

# Guess the archive type from its headers
# USAGE: archive_guess_type_from_headers $archive_path
# RETURNS: the archive type,
#          or an empty string is none could be guessed
archive_guess_type_from_headers() {
	local archive_path
	archive_path="$1"

	local archive_type
	if head --lines=20 "$archive_path" | grep --quiet 'Makeself'; then
		if head --lines=50 "$archive_path" | grep --quiet 'script="./startmojo.sh"'; then
			archive_type='mojosetup'
		else
			archive_type='makeself'
		fi
	fi

	printf '%s' "${archive_type:-}"
}

# get the extractor for the given archive
# USAGE: archive_extractor $archive_identifier
# RETURNS: the specific extractor to use for the given archive (as a single word string),
#          or an empty string if none has been explicitely set.
archive_extractor() {
	local archive_identifier
	archive_identifier="$1"
	assert_not_empty 'archive_identifier' 'archive_extractor'

	# Return archive extractor early if it is already set
	local archive_extractor
	archive_extractor=$(get_value "${archive_identifier}_EXTRACTOR")
	if [ -n "$archive_extractor" ]; then
		printf '%s' "$archive_extractor"
		return 0
	fi

	# Fall back on using the extractor of the parent archive, if there is one
	if \
		printf '%s' "$archive_identifier" | \
		grep --quiet --word-regexp '^ARCHIVE_.*_PART[0-9]\+$'
	then
		local parent_archive
		parent_archive=$(printf '%s' "$archive_identifier" | sed 's/^\(ARCHIVE_.*\)_PART[0-9]\+$/\1/')
		archive_extractor=$(archive_extractor "$parent_archive")
		if [ -n "$archive_extractor" ]; then
			printf '%s' "$archive_extractor"
			return 0
		fi
	fi

	# No failure if no extractor could be found
	return 0
}

# get the extractor options string for the given archive
# USAGE: archive_extractor_options $archive
# RETURNS: the options string to pass to the specific extractor to use for the given archive,
#          or an empty string if no options string has been explicitely set.
archive_extractor_options() {
	local archive
	archive="$1"

	get_value "${archive}_EXTRACTOR_OPTIONS"
}

# check integrity of target file
# USAGE: archive_integrity_check $archive $file ($name)
archive_integrity_check() {
	local archive file name
	archive="$1"
	file="$2"
	name="$3"

	local option_checksum
	option_checksum=$(option_value 'checksum')
	case "$option_checksum" in
		('md5')
			archive_integrity_check_md5 "$archive" "$file" "$name"
		;;
	esac
}

# Print the list of archives supported vby the current game script
# USAGE: archives_return_list
# RETURNS: the list of identifiers of the supported archives,
#          as a list of strings separated by spaces or line breaks
archives_return_list() {
	# If a list is already explicitely set, return early
	if ! variable_is_empty 'ARCHIVES_LIST'; then
		# ShellCheck false-positive
		# Possible misspelling: ARCHIVES_LIST may not be assigned. Did you mean archives_list?
		# shellcheck disable=SC2153
		printf '%s' "$ARCHIVES_LIST"
		return 0
	fi

	# Try to find archives using the ARCHIVE_BASE_xxx_[0-9]+ naming scheme
	local variable_name_pattern archives_list
	variable_name_pattern='^ARCHIVE_BASE\(_[0-9A-Z]\+\)*_[0-9]\+='
	archives_list=$(
		set | \
			grep --regexp="$variable_name_pattern" | \
			cut --delimiter='=' --fields=1
	)
	if [ -n "$archives_list" ]; then
		printf '%s' "$archives_list"
		return 0
	fi

	# Fall back on trying to find archives using the old naming scheme
	if ! version_is_at_least '2.21' "$target_version"; then
		archives_list=$(archives_return_list_legacy)
		if [ -n "$archives_list" ]; then
			printf '%s' "$archives_list"
			return 0
		fi
	fi

	error_no_archive_supported
	return 1
}
