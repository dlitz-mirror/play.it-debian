# display an error when an unknown application type is used
# USAGE: error_unknown_application_type $app_type
error_unknown_application_type() {
	local message application_type
	application_type="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le type dʼapplication "%s" est inconnu.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='"%s" application type is unknown.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$application_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

# Display an error when no application type could be found.
# USAGE: error_no_application_type $application
error_no_application_type() {
	local application
	application="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le type de lʼapplication "%s" nʼest pas défini, et nʼa pas pu être détecté automatiquement.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de suivi des problèmes : %s\n'
		;;
		('en'|*)
			message='The type of application "%s" is not set, and could not be guessed.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$application" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

# Display an error when an unknown prefix type is requested.
# USAGE: error_unknown_prefix_type $prefix_type
error_unknown_prefix_type() {
	local prefix_type
	prefix_type="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le type de préfixe "%s" est inconnu.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de suivi des problèmes : %s\n'
		;;
		('en'|*)
			message='"%s" prefix type is unknown.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac

	print_error
	printf "$message" "$prefix_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

# display an error when using an invalid format for an application id
# USAGE: error_application_id_invalid $application $application_id
error_application_id_invalid() {
	local application application_id
	application="$1"
	application_id="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼid fourni pour lʼapplication %s ne correspond pas au format attendu : "%s"\n'
			message="$message"'Cette valeur ne peut utiliser que des caractères du set [-a-z0-9],'
			message="$message"' et ne peut ni débuter ni sʼachever par un tiret.\n'
		;;
		('en')
			message='The id provided for application %s is not using the expected format: "%s"\n'
			message="$message"'The value should only include characters from the set [-a-z0-9],'
			message="$message"' and can not begin nor end with an hyphen.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$application" "$application_id"
}

# display an error when APP_xxx_EXE is unset but the application requires it
# USAGE: error_application_exe_empty $application $application_type
error_application_exe_empty() {
	local application application_type
	application="$1"
	application_type="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='%s nʼest pas défini, mais cette valeur est requise pour les applications utilisant le type "%s".\n'
		;;
		('en')
			message='%s is not set, but is required for applications using "%" type.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "${application}_EXE" "$application_type"
}

# The applications list for the current game script is empty
# USAGE: error_applications_list_empty
error_applications_list_empty() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La liste dʼapplications à prendre en charge pour ce jeu semble vide'
			message="$message"', mais un traitement de cette liste a été demandé.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='The applications list for the current game seems to be empty'
			message="$message"', but some action on this list has been requested.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac

	print_error
	printf "$message" "$PLAYIT_BUG_TRACKER_URL"
}
