# Warning: A .deb package is going over the 9GB size limit
# USAGE: warning_debian_size_limit $package
warning_debian_size_limit() {
	local package
	package="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le paquet suivant est trop gros pour le format .deb moderne : %s\n'
			message="$message"'Merci de signaler cet avertissement sur notre système de suivi : %s\n\n'
		;;
		('en'|*)
			message='The following package is too big for .deb modern format: %s\n'
			message="$message"'Please report this warning on our issues tracker: %s\n\n'
		;;
	esac
	print_warning
	printf "$message" "$package" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}
