# Error - A binary file is missing
# USAGE: error_launcher_missing_binary $binary
# CALLS: print_error
error_launcher_missing_binary() {
	local binary
	binary="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Le fichier suivant est introuvable, mais la création dʼun lanceur pour celui-ci a été demandée : %s\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='The following file can not be found, but a launcher targeting it should have been created: %s\n'
			message="$message"'Please report this issue on our bug tracker: %s\n'
		;;
	esac
	(
		print_error
		printf "$message" "$binary" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	)
}

# Error - The requested prefix type is not compatible with the given application type
# USAGE: error_launchers_prefix_type_unsupported $application
error_launchers_prefix_type_unsupported() {
	local application
	application="$1"

	local application_type prefix_type
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
	prefix_type=$(application_prefix_type "$application")

	local message
	case "${LANG%_*}" in
		('fr')
			message='Le type de préfixe "%s" ne peut pas être utilisé pour une application du type "%s".\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de suivi des problèmes : %s\n'
		;;
		('en'|*)
			message='Prefix type "%s" can not be used with application type "%s".\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	(
		print_error
		printf "$message" "$prefix_type" "$application_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	)
}

