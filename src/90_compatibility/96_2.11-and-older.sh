# Keep compatibility with 2.11 and older

liberror() {
	error_invalid_argument "$1" "$2"
	return 1
}

archive_set_error_not_found() {
	error_archive_not_found "$@"
	return 1
}

archive_guess_type_error() {
	error_archive_type_not_set "$1"
	return 1
}

archive_print_file_in_use() {
	information_file_in_use "$1"
}

archive_integrity_check_error() {
	error_hashsum_mismatch "$1"
	return 1
}

select_package_architecture_error_unknown() {
	error_architecture_not_supported "$OPTION_ARCHITECTURE"
	return 1
}

select_package_architecture_warning_unsupported() {
	warning_option_not_supported '--architecture'
}

error_no_pkg() {
	error_variable_not_set "$1" '$PKG'
	return 1
}

set_temp_directories_error_no_size() {
	error_variable_not_set 'set_temp_directories' '$ARCHIVE_SIZE'
	return 1
}

prepare_package_layout_error_no_list() {
	error_variable_not_set 'prepare_package_layout' '$PACKAGES_LIST'
	return 1
}

organize_data_error_missing_pkg() {
	error_variable_not_set 'organize_data' '$PKG'
	return 1
}

icon_path_empty_error() {
	error_variable_not_set 'icons_get_from_path' '$'"$1"
	return 1
}

set_temp_directories_error_not_enough_space() {
	# shellcheck disable=SC2046
	error_not_enough_free_space $(temporary_directories_list_candidates)
	return 1
}

archive_extraction_innosetup_error_version() {
	error_innoextract_version_too_old "$1"
	return 1
}

icon_file_not_found_error() {
	error_icon_file_not_found "$1"
	return 1
}

missing_pkg_error() {
	error_invalid_argument 'PKG' "$1"
	return 1
}

pkg_build_print_already_exists() {
	information_package_already_exists "$1"
}

archive_integrity_check_print() {
	information_file_integrity_check "$1"
}

extract_data_from_print() {
	information_archive_data_extraction "$1"
}

pkg_print() {
	information_package_building "$1"
}

# display an error when the selected architecture is not supported
# USAGE: error_architecture_not_supported $architecture
error_architecture_not_supported() {
	local message architecture
	architecture="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchitecture demandée nʼest pas gérée : %s\n'
		;;
		('en'|*)
			message='Selected architecture is not supported: %s\n'
		;;
	esac
	print_error
	printf "$message" "$architecture"
}

# display an error if there is not enough free storage space
# print a list of directories that have been scanned for available space
# USAGE: error_not_enough_free_space $directory[…]
error_not_enough_free_space() {
	local message directory
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Il nʼy a pas assez dʼespace libre dans les différents répertoires testés :\n'
		;;
		('en'|*)
			message='There is not enough free space in the tested directories:\n'
		;;
	esac
	print_error
	printf "$message"
	for directory in "$@"; do
		printf '%s\n' "$directory"
	done
}

# display a warning when using an option not supported by the current script
# USAGE: warning_option_not_supported $option
warning_option_not_supported() {
	local message option
	option="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼoption %s nʼest pas gérée par ce script.\n'
		;;
		('en'|*)
			message='%s option is not supported by this script.\n'
		;;
	esac
	print_warning
	printf "$message" "$option"
}

# print integrity check message
# USAGE: information_file_integrity_check $file
information_file_integrity_check() {
	local message file
	file=$(basename "$1")
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Contrôle de lʼintégrité de %s'
		;;
		('en'|*)
			message='Checking integrity of %s'
		;;
	esac
	printf "$message" "$file"
}

