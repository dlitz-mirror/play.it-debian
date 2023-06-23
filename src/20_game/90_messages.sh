# Error - An invalid format is used for game id
# USAGE: error_game_id_invalid $game_id
error_game_id_invalid() {
	local game_id
	game_id="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Lʼid de jeu fourni ne correspond pas au format attendu : "%s"\n'
			message="$message"'Cette valeur ne peut utiliser que des caractères du set [-a-z0-9],'
			message="$message"' et ne peut ni débuter ni sʼachever par un tiret.\n'
		;;
		('en'|*)
			message='The provided game id is not using the expected format: "%s"\n'
			message="$message"'The value should only include characters from the set [-a-z0-9],'
			message="$message"' and can not begin nor end with an hyphen.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$game_id"
	)
}

