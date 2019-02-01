# display an error if a function is called without an argument
# USAGE: error_missing_argument $function
# CALLS: print_error
error_missing_argument() {
	local function
	function="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='La fonction "%s" ne peut pas être appelée sans argument.\n'
		;;
		('en'|*)
			string='"%s" function can not be called without an argument.\n'
		;;
	esac
	printf "$string" "$function"
	exit 1
}

# display an error if a function is called more than one argument
# USAGE: error_extra_arguments $function
# CALLS: print_error
error_extra_arguments() {
	local function
	function="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='La fonction "%s" ne peut pas être appelée avec plus d’un argument.\n'
		;;
		('en'|*)
			string='"%s" function can not be called with mor than one single argument.\n'
		;;
	esac
	printf "$string" "$function"
	exit 1
}

# display an error if function is called while $PKG is unset
# USAGE: error_no_pkg $function
# CALLS: print_error
error_no_pkg() {
	local function
	function="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			# shellcheck disable=SC1112
			string='La fonction "%s" ne peut pas être appelée lorsque $PKG n’a pas de valeur définie.\n'
		;;
		('en'|*)
			string='"%s" function can not be called when $PKG is not set.\n'
		;;
	esac
	printf "$string" "$function"
	exit 1
}

