# display an error message if an icon dependency is missing
# USAGE: error_icon_dependency_not_found $command_name
# NEEDED VARS: (LANG)
# CALLED BY: check_deps
error_icon_dependency_not_found() {
	local message command_name
	command_name="$1"
	set +o errexit
	error_dependency_not_found "$command_name"
	set -o errexit
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Vous pouvez aussi utiliser --icons=no ou --icons=auto\n'
		;;
		('en'|*)
			message='You can also use --icons=no or --icons=auto\n'
		;;
	esac
	printf "$message"
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
}

