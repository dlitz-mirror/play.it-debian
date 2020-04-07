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

# print notification about required overlays when building Gentoo packages
# USAGE: information_required_gentoo_overlays $overlays
information_required_gentoo_overlays() {
	local message overlays
	overlays="$1"
	case "${LANG%_*}" in
		('fr')
			message='\nVous pouvez avoir besoin des overlays suivants pour installer ces paquets : %s\n'
		;;
		('en'|*)
			message='\nYou may need the following overlays to install these packages: %s\n'
		;;
	esac
	printf "$printf" "$overlays"
	return 0
}

# print common part of packages installation instructions
# USAGE: information_installation_instructions_common $game_name
information_installation_instructions_common() {
	local message game_name
	game_name="$1"
	case "${LANG%_*}" in
		('fr')
			message='\nInstallez "%s" en lançant la série de commandes suivantes en root :\n'
		;;
		('en'|*)
			message='\nInstall "%s" by running the following commands as root:\n'
		;;
	esac
	printf "$message" "$game_name"
}

# print variant precision for packages installation instructions
# USAGE: information_installation_instructions_variant $variant
information_installation_instructions_variant() {
	local message variant
	variant="$1"
	case "${LANG%_*}" in
		('fr')
			message='\nversion %s :\n'
		;;
		('en'|*)
			message='\n%s version:\n'
		;;
	esac
	printf "$message" "$variant"
	return 0
}

# add comment to packages installation instructions on Gentoo
# USAGE: information_installation_instructions_gentoo_comment
information_installation_instructions_gentoo_comment() {
	local message
	case "${LANG%_*}" in
		('fr')
			message='ou mettez les paquets dans un PKGDIR (dans un dossier nommé games-playit) et emergez-les'
		;;
		('en'|*)
			message='or put the packages in a PKGDIR (in a folder named games-playit) and emerge them'
		;;
	esac
	printf "$message"
	return 0
}

