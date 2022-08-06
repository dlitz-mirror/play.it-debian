# diplay an error message if an icon file can not be found
# USAGE: error_icon_file_not_found $file
error_icon_file_not_found() {
	local message file
	file="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le fichier dʼicône suivant est introuvable : %s\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='The following icon file could not be found: %s\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$file" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

# display an error when the path to a given icon is unset but we try to use it
# USAGE: error_icon_path_empty $icon
error_icon_path_empty() {
	local icon
	icon="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='%s nʼest pas défini, mais il y a eu une tentative de récupérer le chemin de cette icône.\n'
		;;
		('en')
			message='%s is not set, but there has been a request for this icon path.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$icon"
}

# An icon file with an unsupported MIME type has been passed
# USAGE: error_icon_unsupported_type $icon_file $icon_type
error_icon_unsupported_type() {
	local icon_file icon_type message
	icon_file="$1"
	icon_type="$2"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le fichier dʼicône suivant est du type MIME "%s", qui nʼest pas pris en charge : %s\n'
		;;
		('en'|*)
			message='The following icon file is of the "%s" MIME type, that is not supported: %s\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$icon_type" "$icon_file"
}

