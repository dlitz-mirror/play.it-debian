# Apply minimal permissions on all files in the given paths:
# - 755 for directories
# - 644 for files
# USAGE: set_standard_permissions $path[…]
set_standard_permissions() {
	local path
	for path in "$@"; do
		# Error out if something does not look like a path to a directory
		if [ ! -d "$path" ]; then
			return 1
		fi
		find "$path" -type d -exec chmod 755 '{}' +
		find "$path" -type f -exec chmod 644 '{}' +
	done
}

# convert files name to lower case
# USAGE: tolower $dir[…]
# CALLS: tolower_convmv tolower_shell
tolower() {
	local directory
	for directory in "$@"; do
		if [ ! -d "$directory" ]; then
			error_not_a_directory "$directory"
			return 1
		fi
		if command -v convmv > /dev/null; then
			tolower_convmv "$directory"
		else
			tolower_shell "$directory"
		fi
	done
}

# convert files name to lower case using convmv
# USAGE: tolower_convmv $directory
# RETURN: nothing
# SIDE EFFECT: convert all file names in a given path to lowercase
tolower_convmv() {
	debug_entering_function 'tolower_convmv'

	local directory convmv_options find_options
	directory="$1"
	convmv_options='-f utf8 --notest --lower -r'
	find_options='-mindepth 1 -maxdepth 1'

	# Hide convmv output unless $PLAYIT_OPTION_DEBUG is set to ≥ 1
	local option_debug
	option_debug=$(option_value 'debug')
	if [ "$option_debug" -ge 1 ]; then
		# shellcheck disable=SC2086
		find "$directory" $find_options -exec \
			convmv $convmv_options {} +
	else
		# shellcheck disable=SC2086
		find "$directory" $find_options -exec \
			convmv $convmv_options {} + >/dev/null 2>&1
	fi

	debug_leaving_function 'tolower_convmv'
}

# convert files name to lower case using pure shell
# USAGE: tolower_shell $dir
# CALLED BY: tolower
tolower_shell() {
	local dir="$1"

	find "$dir" -depth -mindepth 1 | while read -r file; do
		newfile=$(dirname "$file")/$(basename "$file" | tr '[:upper:]' '[:lower:]')
		[ -e "$newfile" ] || mv "$file" "$newfile"
	done
}

# convert files name to upper case
# USAGE: toupper $dir[…]
# CALLS: toupper_convmv toupper_shell
toupper() {
	local directory
	for directory in "$@"; do
		if [ ! -d "$directory" ]; then
			error_not_a_directory "$directory"
			return 1
		fi
		if command -v convmv > /dev/null; then
			toupper_convmv "$directory"
		else
			toupper_shell "$directory"
		fi
	done
}

# convert files name to upper case using convmv
# USAGE: toupper_convmv $directory
# RETURN: nothing
# SIDE EFFECT: convert all file names in a given path to uppercase
toupper_convmv() {
	debug_entering_function 'toupper_convmv'

	local convmv_options find_options directory
	directory="$1"
	convmv_options='-f utf8 --notest --upper -r'
	find_options='-mindepth 1 -maxdepth 1'

	# Hide convmv output unless $PLAYIT_OPTION_DEBUG is set to ≥ 1
	local option_debug
	option_debug=$(option_value 'debug')
	if [ "$option_debug" -ge 1 ]; then
		# shellcheck disable=SC2086
		find "$directory" $find_options -exec \
			convmv $convmv_options {} +
	else
		# shellcheck disable=SC2086
		find "$directory" $find_options -exec \
			convmv $convmv_options {} + >/dev/null 2>&1
	fi

	debug_leaving_function 'toupper_convmv'
}

# convert files name to upper case using pure shell
# USAGE: toupper_shell $dir
# CALLED BY: toupper
toupper_shell() {
	local dir="$1"

	find "$dir" -depth -mindepth 1 | while read -r file; do
		newfile="$(dirname "$file")/$(basename "$file" | tr '[:lower:]' '[:upper:]')"
		[ -e "$newfile" ] || mv "$file" "$newfile"
	done
}

# try to guess the tar implementation used for `tar` on the current system
# USAGE: guess_tar_implementation
guess_tar_implementation() {
	case "$(tar --version | head --lines 1)" in
		(*'GNU tar'*)
			PLAYIT_TAR_IMPLEMENTATION='gnutar'
		;;
		(*'libarchive'*)
			PLAYIT_TAR_IMPLEMENTATION='bsdtar'
		;;
		(*)
			error_unknown_tar_implementation
			return 1
		;;
	esac
}

# Return the MIME type of a given file
# USAGE: file_type $file
# RETURNS: the MIME type, as a string
file_type() {
	local file
	file="$1"

	local file_type
	file_type=$(file --brief --dereference --mime-type "$file")

	# Everything behind the first ";" is removed,
	# so "application/x-executable; charset=binary"
	# would be returned as "application/x-executable".
	file_type=$(printf '%s' "$file_type" | cut --delimiter=';' --fields=1)

	printf '%s' "$file_type"
}
