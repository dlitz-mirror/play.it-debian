# print OK
# USAGE: print_ok
print_ok() {
	printf '\t\033[1;32mOK\033[0m\n'
}

# print a localized error message
# USAGE: print_error
print_error() {
	local string
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			string='Erreur :'
		;;
		('en'|*)
			string='Error:'
		;;
	esac
	exec 1>&2
	printf '\n\033[1;31m%s\033[0m\n' "$string"
}

# print a localized warning message
# USAGE: print_warning
print_warning() {
	local string
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			string='Avertissement :'
		;;
		('en'|*)
			string='Warning:'
		;;
	esac
	printf '\n\033[1;33m%s\033[0m\n' "$string"
}

