# Display a warning when setting an option to a deprecated value
# USAGE: warning_option_value_deprecated $option_name $option_value
warning_option_value_deprecated() {
	local option_name option_value
	option_name="$1"
	option_value="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La valeur suivante est dépréciée pour lʼoption "%s", et ne sera plus acceptée dans une future version : "%s"\n\n'
		;;
		('en'|*)
			message='The following value is deprecated for option "%s", and will no longer be supported with some future update: "%s"\n\n'
		;;
	esac
	print_warning >/dev/stderr
	printf "$message" "$option_name" "$option_value" >/dev/stderr
}

# Error - An unknown option has been provided
# USAGE: error_option_unknown $option_name
error_option_unknown() {
	local option_name
	option_name="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Option inconnue : %s\n'
		;;
		('en'|*)
			message='Unkown option: %s\n'
		;;
	esac
	(
		print_error
		printf "$message" "$option_name"
	)
}

# Error - An invalid value has been provided for the given option
# USAGE: error_option_invalid $option_name $option_value
error_option_invalid() {
	local option_name option_value
	option_name="$1"
	option_value="$2"

	local message
	case "${LANG%_*}" in
		('fr')
			message='"%s" nʼest pas une valeur valide pour --%s.\n'
		;;
		('en'|*)
			message='"%s" is not a valid value for --%s.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$option_value" "$option_name"
	)
}

# Error - The configuration file could not be found
# USAGE: error_config_file_not_found $config_file_path
error_config_file_not_found() {
	local config_file_path
	config_file_path="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Le fichier de configuration %s nʼa pas pu être trouvé.\n'
			;;
		('en'|*)
			message='The configuration file %s has not been found.\n'
			;;
	esac
	(
		print_error
		printf "$message" "$config_file_path"
	)
}

# Error - Some options are currently set to incompatible values
# USAGE: error_incompatible_options $option_name_1 $option_name_2
error_incompatible_options() {
	local option_name_1 option_name_2
	option_name_1="$1"
	option_name_2="$2"

	local option_value_1 option_value_2
	option_value_1=$(option_value "$option_name_1")
	option_value_2=$(option_value "$option_name_2")

	local message
	case "${LANG%_*}" in
		('fr')
			message='Les options suivantes ne sont pas compatibles :\n'
			message="$message"'\t--%s %s\n'
			message="$message"'\t--%s %s\n\n'
		;;
		('en'|*)
			message='The following options are not compatible:\n'
			message="$message"'\t--%s %s\n'
			message="$message"'\t--%s %s\n\n'
		;;
	esac
	(
		print_error
		printf "$message" \
			"$option_name_1" "$option_value_1" \
			"$option_name_2" "$option_value_2"
	)
}

