# Keep compatibility with 2.15 and older

extract_data_from() {
	local archive_path_from_environment archive_path_from_parameters
	archive_path_from_environment=$(archive_find_path "$ARCHIVE")
	archive_path_from_parameters="$1"
	local archive_path_from_environment_real archive_path_from_parameters_real
	archive_path_from_environment_real=$(realpath --canonicalize-existing "$archive_path_from_environment")
	archive_path_from_parameters_real=$(realpath --canonicalize-existing "$archive_path_from_parameters")
	if [ "$archive_path_from_environment_real" != "$archive_path_from_parameters_real" ]; then
		local message game_name
		game_name=$(game_name)
		# shellcheck disable=SC2031
		case "${LANG%_*}" in
			('fr')
				message='La prise en charge de "%s" utilise du code obsolète qui nʼest plus fonctionnel.\n'
				message="$message"'La fonction ayant déclenché cette erreur est : %s\n'
				message="$message"'Merci de signaler cette erreur sur notre système de suivi : %s\n'
			;;
			('en'|*)
				message='Support for "%s" is relying on obsolete code that no longer works.\n'
				message="$message"'The function that triggered this error is: %s\n'
				message="$message"'Please report this error on our issues tracker: %s\n'
			;;
		esac
		print_error
		printf "$message" "$game_name" 'extract_data_from' "$PLAYIT_GAMES_BUG_TRACKER_URL"
		return 1
	fi
	archive_extraction "$ARCHIVE"
}

