# the current package is not part of the full list of packages to generate
# USAGE: error_package_not_in_list $package
error_package_not_in_list() {
	local message package
	package="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Cet identifiant de paquet ne correspond pas à un paquet à construire : %s\n'
		;;
		('en'|*)
			message='The following package identifier is not part of the list of packages to generate: %s\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$package"
}

# display a warning when output package format guessing failed
# USAGE: warning_package_format_guessing_failed $fallback_value
warning_package_format_guessing_failed() {
	local message fallback_value
	fallback_value="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼauto-détection du format de paquet le plus adapté a échoué.\n'
			message="$message"'Le format de paquet %s sera utilisé par défaut.\n'
		;;
		('en'|*)
			message='Most pertinent package format auto-detection failed.\n'
			message="$message"'%s package format will be used by default.\n'
		;;
	esac
	print_warning
	printf "$message" "$fallback_value"
}

# display a notification when trying to build a package that already exists
# USAGE: information_package_already_exists $file
information_package_already_exists() {
	local message file
	file="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='%s existe déjà.\n'
		;;
		('en'|*)
			message='%s already exists.\n'
		;;
	esac
	printf "$message" "$file"
}

# print package building message
# USAGE: information_package_building $file
information_package_building() {
	local message file
	file="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Construction de %s…\n'
		;;
		('en'|*)
			message='Building %s…\n'
		;;
	esac
	# shellcheck disable=SC2059
	printf "$message" "$file"
}

# print package building message
# USAGE: information_package_building $file
information_package_building_done() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Contruction terminée !'
		;;
		('en'|*)
			message='Building done!'
		;;
	esac
	printf '%s\n' "$message"
}

