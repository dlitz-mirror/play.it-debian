# display an error when called with an unknown option
# USAGE: error_option_unknown $option_name
error_option_unknown() {
	local message option_name
	option_name="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Option inconnue : %s\n'
		;;
		('en'|*)
			message='Unkown option: %s\n'
		;;
	esac
	print_error
	printf "$message" "$option_name"
}

# display an error when the config file is not found
# USAGE: error_config_file_not_found $config_file_path
error_config_file_not_found() {
	local message
	local config_file_path

	config_file_path="$1"

	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le fichier de configuration %s nʼa pas pu être trouvé.\n'
			;;
		('en'|*)
			message='The configuration file %s has not been found.\n'
			;;
	esac
	print_error
	printf "$message" "$config_file_path"
}

