# Error - A required dependency is missing
# USAGE: error_dependency_not_found $command_name
error_dependency_not_found() {
	local command_name provider_package
	command_name="$1"
	provider_package=$(dependency_provided_by "$command_name")

	local message
	case "${LANG%_*}" in
		('fr')
			message='%s est introuvable. Installez %s avant de lancer ce script.\n'
		;;
		('en'|*)
			message='%s not found. Install %s before running this script.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$command_name" "$provider_package"
	)
}

