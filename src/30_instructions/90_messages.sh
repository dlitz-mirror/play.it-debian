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

