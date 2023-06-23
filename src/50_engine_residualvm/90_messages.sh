# Error - The provided ResidualVM id uses an invalid format
# USAGE: error_application_residualid_invalid $application $application_residualid
error_application_residualid_invalid() {
	local application application_residualid
	application="$1"
	application_residualid="$2"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Lʼid ResidualVM fourni pour lʼapplication %s ne semble pas correct : "%s"\n'
		;;
		('en')
			message='The ResidualVM id provided for application %s does not seem correct: "%s"\n'
		;;
	esac
	(
		print_error
		printf "$message" "$application" "$application_residualid"
	)
}

