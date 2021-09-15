# set defaults rights on files (755 for dirs & 644 for regular files)
# USAGE: set_standard_permissions $dir[…]
set_standard_permissions() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	for dir in "$@"; do
		[  -d "$dir" ] || return 1
		find "$dir" -type d -exec chmod 755 '{}' +
		find "$dir" -type f -exec chmod 644 '{}' +
	done
}

# convert files name to lower case
# USAGE: tolower $dir[…]
# CALLS: tolower_convmv tolower_shell
tolower() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	for dir in "$@"; do
		[ -d "$dir" ] || return 1
		if command -v convmv > /dev/null; then
			tolower_convmv "$dir"
		else
			tolower_shell "$dir"
		fi
	done
}

# convert files name to lower case using convmv
# USAGE: tolower_convmv $directory
# RETURN: nothing
# SIDE EFFECT: convert all file names in a given path to lowercase
tolower_convmv() {
	# shellcheck disable=SC2039
	local directory
	directory="$1"

	###
	# TODO
	# Check that $directory is a writable directory
	###

	# shellcheck disable=SC2039
	local convmv_options
	convmv_options='-f utf8 --notest --lower -r'

	# shellcheck disable=SC2086
	find "$directory" -mindepth 1 -maxdepth 1 -exec \
		convmv $convmv_options {} + >/dev/null 2>&1
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
	[ "$DRY_RUN" = '1' ] && return 0
	for dir in "$@"; do
		[ -d "$dir" ] || return 1
		if command -v convmv > /dev/null; then
			toupper_convmv "$dir"
		else
			toupper_shell "$dir"
		fi
	done
}

# convert files name to upper case using convmv
# USAGE: toupper_convmv $directory
# RETURN: nothing
# SIDE EFFECT: convert all file names in a given path to uppercase
toupper_convmv() {
	# shellcheck disable=SC2039
	local directory
	directory="$1"

	###
	# TODO
	# Check that $directory is a writable directory
	###

	# shellcheck disable=SC2039
	local convmv_options
	convmv_options='-f utf8 --notest --upper -r'

	# shellcheck disable=SC2086
	find "$directory" -mindepth 1 -maxdepth 1 -exec \
		convmv $convmv_options {} + >/dev/null 2>&1
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

# check that the value assigned to a given option is valid
# USAGE: check_option_validity $option_name
# CALLS: error_option_invalid
check_option_validity() {
	local option_name option_value allowed_values
	option_name="$1"
	option_value=$(get_value "OPTION_${option_name}")
	allowed_values=$(get_value "ALLOWED_VALUES_${option_name}")
	for allowed_value in $allowed_values; do
		if [ "$option_value" = "$allowed_value" ]; then
			# leaves the function with a success code if the tested value is valid
			return 0
		fi
	done
	# if we did not leave the function before this point, the tested value is not valid
	option_name=$(printf '%s' "$option_name" | tr '[:upper:]' '[:lower:]')
	if [ "$option_name" = 'compression' ]; then
		error_compression_invalid
	else
		error_option_invalid "$option_name" "$option_value"
	fi
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
		;;
	esac
}

