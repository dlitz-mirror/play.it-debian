# display a warning when using an option not supported by the current script
# USAGE: warning_option_not_supported $option
warning_option_not_supported() {
	local message option
	option="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼoption %s nʼest pas gérée par ce script.\n'
		;;
		('en'|*)
			message='%s option is not supported by this script.\n'
		;;
	esac
	print_warning
	printf "$message" "$option"
	return 0
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
	return 0
}

# display a warning message if an icon dependency is missing
# USAGE: warning_icon_dependency_not_found $dependency
# NEEDED VARS: (LANG)
# CALLED BY: check_deps
warning_icon_dependency_not_found() {
	local message dependency
	dependency="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='%s est introuvable. Installez-le pour inclure les icônes.\n'
			message="$message"'Vous pouvez aussi utiliser --icons=no ou --icons=yes\n\n'
		;;
		('en'|*)
			message='%s not found. Install it to include icons.\n'
			message="$message"'You can also use --icons=no or --icons=yes\n\n'
		;;
	esac
	print_warning
	printf "$message" "$dependency"
	return 0
}

# display a warning when using a library not available on target system in a
# given architecture
# USAGE: warning_missing_library $lib $target_system $architecture
warning_missing_library() {
	local lib
	local target_system
	local architecture
	lib="$1"
	target_system="$2"
	architecture="$3"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La bibliothèque %s nʼest pas disponible pour %s (architecture %s).\n'
		;;
		('en'|*)
			message='The library %s is not available on %s (%s architecture).\n'
		;;
	esac
	print_warning
	printf "$message" "$lib" "$target_system" "$architecture"
	return 0
}

# display a warning when some game script uses a deprecated archive type
# USAGE: warning_archive_type_deprecated $archive
warning_archive_type_deprecated() {
	local archive
	archive="$1"

	local archive_type
	archive_type=$(archive_get_type "$archive")

	local game_name
	game_name=$(game_name)

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La prise en charge de "%s" utilise un type dʼarchive déprécié : %s\n'
			message="$message"'Merci de signaler cet avertissement sur notre système de suivi : %s\n'
		;;
		('en'|*)
			message='Support for "%s" is using an obsolete archive type: %s\n'
			message="$message"'Please report this warning on our issues tracker: %s\n'
		;;
	esac

	print_warning
	printf "$message" "$game_name" "$archive_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

