# Information: A huge file is split into 9GB chunks
# USAGE: information_huge_file_split $path_file
information_huge_file_split() {
	local path_file
	path_file="$1"
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Découpage de %s en plusieurs fichiers…\n'
		;;
		('en'|*)
			message='Splitting %s into smaller chunks…\n'
		;;
	esac
	printf "$message" "$path_file"
}
