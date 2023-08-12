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

# Display a list of unknown Mono libraries from packages dependencies
# USAGE: warning_dependencies_unknown_mono_libraries
warning_dependencies_unknown_mono_libraries() {
	local message1 message2
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message1='Certaines dépendances Mono de ce jeu ne sont pas encore prises en charge par ./play.it'
			message1="$message1"', voici la liste de celles qui ont été ignorées :'
			message2='Merci de signaler cette liste sur notre système de suivi :'
		;;
		('en'|*)
			message1='Some Mono dependencies of this game are not supported by ./play.it yet'
			message1="$message1"', here are the ones that have been skipped:'
			message2='Please report this list on our issues tracker:'
		;;
	esac
	print_warning
	printf '%s\n' "$message1"
	# shellcheck disable=SC2046
	printf -- '- %s\n' $(dependencies_unknown_mono_libraries_list)
	printf '%s\n%s\n' "$message2" "$PLAYIT_BUG_TRACKER_URL"
}

# Warning: Display a list of unknown GStreamer media formats from packages dependencies
# USAGE: warning_dependencies_unknown_gstreamer_media_formats
warning_dependencies_unknown_gstreamer_media_formats() {
	local message1 message2
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message1='Certains formats multimédia requis par ce jeu ne sont pas encore pris en charge par ./play.it'
			message1="$message1"', voici la liste de ceux qui ont été ignorés :'
			message2='Merci de signaler cette liste sur notre système de suivi :'
		;;
		('en'|*)
			message1='Some media formats required by this game are not supported by ./play.it yet'
			message1="$message1"', here are the ones that have been skipped:'
			message2='Please report this list on our issues tracker:'
		;;
	esac
	print_warning
	printf '%s\n' "$message1"
	# shellcheck disable=SC2046
	local media_format
	while read -r media_format; do
		printf -- '- %s\n' "$media_format"
	done <<- EOL
	$(dependencies_unknown_gstreamer_media_formats_list)
	EOL
	printf '%s\n%s\n' "$message2" "$PLAYIT_BUG_TRACKER_URL"
}

# Error - The provided package id uses an invalid format
# USAGE: error_package_id_invalid $package_id
error_package_id_invalid() {
	local package_id
	package_id="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Lʼid de paquet fourni ne correspond pas au format attendu : "%s"\n'
			message="$message"'Cette valeur ne peut utiliser que des caractères du set [-a-z0-9],'
			message="$message"' et ne peut ni débuter ni sʼachever par un tiret.\n'
		;;
		('en'|*)
			message='The provided package id is not using the expected format: "%s"\n'
			message="$message"'The value should only include characters from the set [-a-z0-9],'
			message="$message"' and can not begin nor end with an hyphen.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$package_id"
	)
}

# Error - The generation of the given package failed.
# USAGE: error_package_generation_failed $package_name
error_package_generation_failed() {
	local package_name
	package_name="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='La génération du paquet suivant a échoué : %s\n'
			message="$message"'Merci de signaler cet échec sur notre système de suivi : %s\n\n'
		;;
		('en'|*)
			message='The generation of the following package failed: %s\n'
			message="$message"'Please report this error on our bugs tracker: %s\n\n'
		;;
	esac
	(
		print_error
		printf "$message" "$package_name" "$PLAYIT_BUG_TRACKER_URL"
	)
}

# Error - The given package does not exist
# USAGE: error_package_does_not_exist $package $calling_function
error_package_does_not_exist() {
	local package calling_function
	package="$1"
	calling_function="$2"

	local packages_list packages_list_formatted
	packages_list=$(packages_get_list)
	packages_list_formatted=$(printf '%s ' $packages_list | sed 's/\s\+$//')

	local message
	case "${LANG%_*}" in
		('fr')
			message='The function "%s" has been given a package identifier that is not part of the list of packages to generate: %s\n'
			message="$message"'The packages to build are: %s\n\n'
		;;
		('en'|*)
			message='The function "%s" has been given a package identifier that is not part of the list of packages to generate: %s\n'
			message="$message"'The packages to build are: %s\n\n'
		;;
	esac
	(
		print_error
		printf "$message" "$calling_function" "$package" "$packages_list_formatted"
	)
}

