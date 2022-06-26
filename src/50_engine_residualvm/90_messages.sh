# display an error when using an invalid format for an application ResidualVM id
# USAGE: error_application_residualid_invalid $application $application_residualid
error_application_residualid_invalid() {
	local application application_residualid
	application="$1"
	application_residualid="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼid ResidualVM fourni pour lʼapplication %s ne semble pas correct : "%s"\n'
			message="$message"'Une liste de valeurs acceptées peut se trouver sur le site Web de ResidualVM : \n%s\n'
		;;
		('en')
			message='The ResidualVM id provided for application %s does not seem correct: "%s"\n'
			message="$message"'A list of valid values can be found on ResidualVM website: \n%s\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" \
		"$application" \
		"$application_residualid" \
		'https://www.residualvm.org/compatibility/'
}

