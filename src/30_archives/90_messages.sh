# display an error when trying to extract an archive but no extractor is present
# USAGE: error_archive_no_extractor_found $archive_type
error_archive_no_extractor_found() {
	local message archive_type
	archive_type="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Ce script a essayé dʼextraire le contenu dʼune archive de type "%s", mais aucun outil approprié nʼa été trouvé.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='This script tried to extract the contents of a "%s" archive, but not appropriate tool could be found.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$archive_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

# display an error message when a required archive is not found
# list all the archives that could fulfill the requirement, with their download URL if one is provided
# USAGE: error_archive_not_found $archive[…]
error_archive_not_found() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			if [ $# -eq 1 ]; then
				message='Le fichier suivant est introuvable :\n'
			else
				message='Aucun des fichiers suivants nʼest présent :\n'
			fi
		;;
		('en'|*)
			if [ $# -eq 1 ]; then
				message='The following file could not be found:\n'
			else
				message='None of the following files could be found:\n'
			fi
		;;
	esac
	print_error
	printf "$message"
	information_archives_list "$@"
}

# display an error message when we failed to guess the type of an archive
# USAGE: error_archive_type_not_set $archive
error_archive_type_not_set() {
	local message archive
	archive="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='ARCHIVE_TYPE nʼest pas défini pour %s et nʼa pas pu être détecté automatiquement.\n'
		;;
		('en'|*)
			message='ARCHIVE_TYPE is not set for %s and could not be guessed.\n'
		;;
	esac
	print_error
	printf "$message" "$archive"
}

# display an error message when an integrity check fails
# USAGE: error_hashsum_mismatch $file
error_hashsum_mismatch() {
	local message file
	file=$(basename "$1")
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Somme de contrôle incohérente. %s nʼest pas le fichier attendu.\n'
			message="$message"'Utilisez --checksum=none pour forcer son utilisation.\n'
		;;
		('en'|*)
			message='Hashsum mismatch. %s is not the expected file.\n'
			message="$message"'Use --checksum=none to force its use.\n'
		;;
	esac
	print_error
	printf "$message" "$file"
}

# print error when available version of innoextract is too old
# USAGE: error_innoextract_version_too_old $archive
error_innoextract_version_too_old() {
	local message archive
	archive="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La version de innoextract disponible sur ce système est trop ancienne pour extraire les données de lʼarchive suivante : %s\n'
			message="$message"'Des instructions de mise-à-jour sont proposées :\n'
			message="$message"'- pour Debian : %s\n'
			message="$message"'- pour Ubuntu : %s\n'
		;;
		('en'|*)
			message='Available innoextract version is too old to extract data from the following archive: %s\n'
			message="$message"'Update instructions are proposed:\n'
			message="$message"'- for Debian: %s\n'
			message="$message"'- for Ubuntu: %s\n'
		;;
	esac
	print_error
	printf "$message" "$archive" \
		'https://forge.dotslashplay.it/play.it/doc/-/wikis/distributions/debian#available-innoextract-version-is-too-old' \
		'https://forge.dotslashplay.it/play.it/doc/-/wikis/distributions/ubuntu#innoextract-version-is-too-old'
}

# display a warning when some game script uses a deprecated archive type
# USAGE: warning_archive_type_deprecated $archive
warning_archive_type_deprecated() {
	local archive
	archive="$1"

	local archive_type
	archive_type=$(archive_get_type "$archive")

	local game_name
	game_name=$(game_name)

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La prise en charge de "%s" utilise un type dʼarchive déprécié : %s\n'
			message="$message"'Merci de signaler cet avertissement sur notre système de suivi : %s\n'
		;;
		('en'|*)
			message='Support for "%s" is using an obsolete archive type: %s\n'
			message="$message"'Please report this warning on our issues tracker: %s\n'
		;;
	esac

	print_warning
	printf "$message" "$game_name" "$archive_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

# display the name of a file currently processed
# USAGE: information_file_in_use $file
information_file_in_use() {
	local message file
	file="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Utilisation de %s\n'
		;;
		('en'|*)
			message='Using %s\n'
		;;
	esac
	printf "$message" "$file"
}

# print data extraction message
# USAGE: information_archive_data_extraction $file
information_archive_data_extraction() {
	local message file
	file="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Extraction des données de %s…\n'
		;;
		('en'|*)
			message='Extracting data from %s…\n'
		;;
	esac
	# shellcheck disable=SC2059
	printf "$message" "$file"
}

# print hash computation message
# USAGE: info_archive_hash_computation $file
info_archive_hash_computation() {
	local file message
	file=$(basename "$1")
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Calcul de la somme de contrôle de %s…\n'
		;;
		('en'|*)
			message='Computing hashsum for %s…\n'
		;;
	esac
	# shellcheck disable=SC2059
	printf "$message" "$file"
}

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
}

