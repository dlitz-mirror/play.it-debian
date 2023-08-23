# Error - The provided ScummVM id uses an invalid format
# USAGE: error_application_scummid_invalid $application $application_scummid
error_application_scummid_invalid() {
	local application application_scummid
	application="$1"
	application_scummid="$2"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Lʼid ScummVM fourni pour lʼapplication %s ne semble pas correct : "%s"\n'
			message="$message"'Une liste de valeurs acceptées peut se trouver sur le site Web de ScummVM : \n%s\n'
		;;
		('en')
			message='The ScummVM id provided for application %s does not seem correct: "%s"\n'
			message="$message"'A list of valid values can be found on ScummVM website: \n%s\n'
		;;
	esac
	(
		print_error
		printf "$message" \
			"$application" \
			"$application_scummid" \
			'https://www.scummvm.org/compatibility/'
	)
}

