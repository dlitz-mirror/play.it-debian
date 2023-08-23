# print common part of packages installation instructions
# USAGE: information_installation_instructions_common $game_name
information_installation_instructions_common() {
	local message game_name
	game_name="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\nInstallez "%s" en lançant la série de commandes suivantes en root :\n'
		;;
		('en'|*)
			message='\nInstall "%s" by running the following commands as root:\n'
		;;
	esac
	printf "$message" "$game_name"
}

# print variant precision for packages installation instructions
# USAGE: information_installation_instructions_variant $variant
information_installation_instructions_variant() {
	local message variant
	variant="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\nversion %s :\n'
		;;
		('en'|*)
			message='\n%s version:\n'
		;;
	esac
	printf "$message" "$variant"
}

# Display a list of unknown runtime commands from packages dependencies
# USAGE: warning_dependencies_unknown_commands
warning_dependencies_unknown_commands() {
	local message1 message2
	case "${LANG%_*}" in
		('fr')
			message1='Certaines dépendances de ce jeu ne sont pas encore prises en charge par ./play.it'
			message1="$message1"', voici la liste de celles qui ont été ignorées :\n'
			message2='Merci de signaler cette liste sur notre système de suivi :\n%s\n'
		;;
		('en'|*)
			message1='Some dependencies of this game are not supported by ./play.it yet'
			message1="$message1"', here are the ones that have been skipped:\n'
			message2='Please report this list on our issues tracker:\n%s\n'
		;;
	esac
	print_warning
	printf "$message1"
	# shellcheck disable=SC2046
	printf -- '- %s\n' $(dependencies_unknown_commands_list)
	printf "$message2" "$PLAYIT_BUG_TRACKER_URL"
}

# Display a list of unknown libraries from packages dependencies
# USAGE: warning_dependencies_unknown_libraries
warning_dependencies_unknown_libraries() {
	local message1 message2
	case "${LANG%_*}" in
		('fr')
			message1='Certaines dépendances de ce jeu ne sont pas encore prises en charge par ./play.it'
			message1="$message1"', voici la liste de celles qui ont été ignorées :\n'
			message2='Merci de signaler cette liste sur notre système de suivi :\n%s\n'
		;;
		('en'|*)
			message1='Some dependencies of this game are not supported by ./play.it yet'
			message1="$message1"', here are the ones that have been skipped:\n'
			message2='Please report this list on our issues tracker:\n%s\n'
		;;
	esac
	print_warning
	printf "$message1"
	# shellcheck disable=SC2046
	printf -- '- %s\n' $(dependencies_unknown_libraries_list)
	printf "$message2" "$PLAYIT_BUG_TRACKER_URL"
}

# Display a list of unknown Mono libraries from packages dependencies
# USAGE: warning_dependencies_unknown_mono_libraries
warning_dependencies_unknown_mono_libraries() {
	local message1 message2
	case "${LANG%_*}" in
		('fr')
			message1='Certaines dépendances Mono de ce jeu ne sont pas encore prises en charge par ./play.it'
			message1="$message1"', voici la liste de celles qui ont été ignorées :\n'
			message2='Merci de signaler cette liste sur notre système de suivi :\n%s\n'
		;;
		('en'|*)
			message1='Some Mono dependencies of this game are not supported by ./play.it yet'
			message1="$message1"', here are the ones that have been skipped:\n'
			message2='Please report this list on our issues tracker:\n%s\n'
		;;
	esac
	print_warning
	printf "$message1"
	# shellcheck disable=SC2046
	printf -- '- %s\n' $(dependencies_unknown_mono_libraries_list)
	printf "$message2" "$PLAYIT_BUG_TRACKER_URL"
}

# Display a list of unknown GStreamer media formats from packages dependencies
# USAGE: warning_dependencies_unknown_gstreamer_media_formats
warning_dependencies_unknown_gstreamer_media_formats() {
	local message1 message2
	case "${LANG%_*}" in
		('fr')
			message1='Certains formats multimédia requis par ce jeu ne sont pas encore pris en charge par ./play.it'
			message1="$message1"', voici la liste de ceux qui ont été ignorés :\n'
			message2='Merci de signaler cette liste sur notre système de suivi :\n%s\n'
		;;
		('en'|*)
			message1='Some media formats required by this game are not supported by ./play.it yet'
			message1="$message1"', here are the ones that have been skipped:\n'
			message2='Please report this list on our issues tracker:\n%s\n'
		;;
	esac
	print_warning
	printf "$message1"
	# shellcheck disable=SC2046
	local media_format
	while read -r media_format; do
		printf -- '- %s\n' "$media_format"
	done <<- EOL
	$(dependencies_unknown_gstreamer_media_formats_list)
	EOL
	printf "$message2" "$PLAYIT_BUG_TRACKER_URL"
}

