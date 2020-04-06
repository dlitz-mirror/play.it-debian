# display a list of archives, one per line, with their download URL if one is provided
# USAGE: information_archives_list $archive[…]
information_archives_list() {
	local archive archive_name archive_url
	for archive in "$@"; do
		archive_name="$(get_value "$archive")"
		archive_url="$(get_value "${archive}_URL")"
		if [ -n "$archive_url" ]; then
			printf '%s — %s\n' "$archive_name" "$archive_url"
		else
			printf '%s\n' "$archive_name"
		fi
	done
	return 0
}

# display the name of a file currently processed
# USAGE: information_file_in_use $file
information_file_in_use() {
	local message file
	file="$1"
	case "${LANG%_*}" in
		('fr')
			message='Utilisation de %s\n'
		;;
		('en'|*)
			message='Using %s\n'
		;;
	esac
	printf "$message" "$file"
	return 0
}

# display a notification when trying to build a package that already exists
# USAGE: information_package_already_exists $file
information_package_already_exists() {
	local message file
	file="$1"
	case "${LANG%_*}" in
		('fr')
			message='%s existe déjà.\n'
		;;
		('en'|*)
			message='%s already exists.\n'
		;;
	esac
	printf "$message" "$file"
	return 0
}

# print integrity check message
# USAGE: information_file_integrity_check $file
information_file_integrity_check() {
	local message file
	file=$(basename "$1")
	case "${LANG%_*}" in
		('fr')
			string='Contrôle de lʼintégrité de %s'
		;;
		('en'|*)
			string='Checking integrity of %s'
		;;
	esac
	printf "$message" "$file"
	return 0
}

# print data extraction message
# USAGE: information_archive_data_extraction $file
information_archive_data_extraction() {
	local message file
	file="$1"
	case "${LANG%_*}" in
		('fr')
			string='Extraction des données de %s'
		;;
		('en'|*)
			string='Extracting data from %s'
		;;
	esac
	printf "$message" "$file"
	return 0
}

# print package building message
# USAGE: information_package_building $file
information_package_building() {
	local message file
	file="$1"
	case "${LANG%_*}" in
		('fr')
			message='Construction de %s'
		;;
		('en'|*)
			message='Building %s'
		;;
	esac
	printf "$message" "$file"
	return 0
}

