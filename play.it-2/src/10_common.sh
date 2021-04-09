# test the validity of the argument given to parent function
# USAGE: testvar $var_name $pattern
testvar() {
	test "${1%%_*}" = "$2"
}

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
# USAGE: tolower_convmv $dir
# CALLED BY: tolower
tolower_convmv() {
	local dir="$1"
	find "$dir" -mindepth 1 -maxdepth 1 -exec \
		convmv --notest --lower -r {} + >/dev/null 2>&1
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
# USAGE: toupper_convmv $dir
# CALLED BY: toupper
toupper_convmv() {
	local dir="$1"
	find "$dir" -mindepth 1 -maxdepth 1 -exec \
		convmv --notest --upper -r {} + >/dev/null 2>&1
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

# get archive-specific value for a given variable name, or use default value
# USAGE: use_archive_specific_value $var_name
use_archive_specific_value() {
	[ -n "$ARCHIVE" ] || return 0
	if ! testvar "$ARCHIVE" 'ARCHIVE'; then
		error_invalid_argument 'ARCHIVE' 'use_archive_specific_value'
	fi
	local name_real
	name_real="$1"
	local name
	name="${name_real}_${ARCHIVE#ARCHIVE_}"
	local value
	while [ "$name" != "$name_real" ]; do
		value="$(get_value "$name")"
		if [ -n "$value" ]; then
			export ${name_real?}="$value"
			return 0
		fi
		name="${name%_*}"
	done
}

# get package-specific value for a given variable name, or use default value
# USAGE: use_package_specific_value $var_name
use_package_specific_value() {
	# get the current package
	local package
	package=$(package_get_current)

	local name_real
	name_real="$1"
	local name
	name="${name_real}_${package#PKG_}"
	local value
	while [ "$name" != "$name_real" ]; do
		value="$(get_value "$name")"
		if [ -n "$value" ]; then
			export ${name_real?}="$value"
			return 0
		fi
		name="${name%_*}"
	done
}

# get the value of a variable and print it
# USAGE: get_value $variable_name
get_value() {
	local name
	local value
	name="$1"
	value="$(eval printf -- '%b' \"\$$name\")"
	printf '%s' "$value"
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

