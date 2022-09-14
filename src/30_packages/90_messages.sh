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

# Display a list of unknown libraries from packages dependencies
# USAGE: warning_dependencies_unknown_libraries
warning_dependencies_unknown_libraries() {
	local message1 message2
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message1='Certaines dépendances de ce jeu ne sont pas encore prises en charge par ./play.it'
			message1="$message1"', voici la liste de celles qui ont été ignorées :'
			message2='Merci de signaler cette liste sur notre système de suivi :'
		;;
		('en'|*)
			message1='Some dependencies of this game are not supported by ./play.it yet'
			message1="$message1"', here are the ones that have been skipped:'
			message2='Please report this list on our issues tracker:'
		;;
	esac
	print_warning
	printf '%s\n' "$message1"
	# shellcheck disable=SC2046
	printf -- '- %s\n' $(dependencies_unknown_libraries_list)
	printf '%s\n%s\n' "$message2" "$PLAYIT_BUG_TRACKER_URL"
}
