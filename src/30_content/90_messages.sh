# No default content path is set
# USAGE: error_no_content_path_default
error_no_content_path_default() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='CONTENT_PATH_DEFAULT nʼest pas défini, mais il a été requis.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='CONTENT_PATH_DEFAULT is not set, but it has been required.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

