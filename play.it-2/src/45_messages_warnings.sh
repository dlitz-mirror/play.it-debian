# display a warning when PKG value is not included in PACKAGES_LIST
# USAGE: warning_skip_package $function_name $package
warning_skip_package() {
	local message function package
	function="$1"
	package="$2"
	case "${LANG%_*}" in
		('fr')
			message='La valeur de PKG fournie à %s ne fait pas partie de la liste de paquets à construire : %s\n'
		;;
		('en'|*)
			message='The PKG value used by %s is not part of the list of packages to build: %s\n'
		;;
	esac
	print_warning
	printf "$message" "$function" "$package"
	return 0
}

# display a warning when the selected architecture is not available
# USAGE: warning_architecture_not_available $architecture
warning_architecture_not_available() {
	local message architecture
	architecture="$1"
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchitecture demandée nʼest pas disponible : %s\n'
		;;
		('en'|*)
			message='Selected architecture is not available: %s\n'
		;;
	esac
	print_warning
	printf "$message" "$architecture"
	return 0
}

# display a warning when using an option not supported by the current script
# USAGE: warning_option_not_supported $option
warning_option_not_supported() {
	local message option
	option="$1"
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

