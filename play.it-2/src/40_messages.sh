# print OK
# USAGE: print_ok
print_ok() {
	printf '\t\033[1;32mOK\033[0m\n'
}

# print a localized error message
# USAGE: print_error
print_error() {
	local string
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

# display an error when a function has been called with an invalid argument
# USAGE: error_invalid_argument $var_name $calling_function
error_invalid_argument() {
	local var value func
	var="$1"
	value="$(get_value "$var")"
	func="$2"
	case "${LANG%_*}" in
		('fr')
			message='Valeur incorrecte pour %s appelée par %s : %s\n'
		;;
		('en'|*)
			message='Invalid value for %s called by %s: %s\n'
		;;
	esac
	print_error
	printf "$message" "$var" "$func" "$value"
	return 1
}

# display an error when a function is called without an argument, but is expecting some
# USAGE: error_missing_argument $function
error_missing_argument() {
	local message function
	function="$1"
	case "${LANG%_*}" in
		('fr')
			message='La fonction "%s" ne peut pas être appelée sans argument.\n'
		;;
		('en'|*)
			message='"%s" function can not be called without an argument.\n'
		;;
	esac
	print_error
	printf "$message" "$function"
	return 1
}

# display an error when a function is called with multiple arguments, but is expecting no more than one
# USAGE: error_extra_arguments $function
error_extra_arguments() {
	local message function
	function="$1"
	case "${LANG%_*}" in
		('fr')
			message='La fonction "%s" ne peut pas être appelée avec plus dʼun argument.\n'
		;;
		('en'|*)
			message='"%s" function can not be called with mor than one single argument.\n'
		;;
	esac
	print_error
	printf "$message" "$function"
	return 1
}

# display an error when a file is expected and something else has been given
# USAGE: error_not_a_file $param
error_not_a_file() {
	local message param
	param="$1"
	case "${LANG%_*}" in
		('fr')
			message='"%s" nʼest pas un fichier valide.\n'
		;;
		('en'|*)
			message='"%s" is not a valid file.\n'
		;;
	esac
	print_error
	printf "$message" "$param"
	return 1
}

# display an error when an unknown application type is used
# USAGE: error_unknown_application_type $app_type
error_unknown_application_type() {
	local message application_type
	application_type="$1"
	case "${LANG%_*}" in
		('fr')
			message='Le type dʼapplication "%s" est inconnu.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='"%s" application type is unknown.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$application_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# display an error when the available tar implementation is not supported
# USAGE: error_unknown_tar_implementation
error_unknown_tar_implementation() {
	local message
	case "${LANG%_*}" in
		('fr')
			message='La version de tar présente sur ce système nʼest pas reconnue.\n'
			message="$message"'./play.it ne peut utiliser que GNU tar ou bsdtar.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='The tar implementation on this system wasnʼt recognized.\n'
			message="$message"'./play.it can only use GNU tar or bsdtar.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$PLAYIT_BUG_TRACKER_URL"
	return 1
}

# display a message when a required dependency is missing
# USAGE: error_dependency_not_found $command_name
error_dependency_not_found() {
	local message command_name provider
	command_name="$1"
	provider="$(dependency_provided_by "$command_name")"
	case "${LANG%_*}" in
		('fr')
			message='%s est introuvable. Installez %s avant de lancer ce script.\n'
		;;
		('en'|*)
			message='%s not found. Install %s before running this script.\n'
		;;
	esac
	print_error
	printf "$message" "$command_name" "$provider"
	return 1
}

# display an error when trying to extract an archive but no extractor is present
# USAGE: error_archive_no_extractor_found $archive_type
error_archive_no_extractor_found() {
	local message archive_type
	archive_type="$1"
	case "${LANG%_*}" in
		('fr')
			message='Ce script a essayé dʼextraire le contenu dʼune archive de type "%s", mais aucun outil approprié nʼa été trouvé.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='This script tried to extract the contents of a "%s" archive, but not appropriate tool could be found.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$archive_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# Display an error when trying to write a launcher for a missing binary
# USAGE: error_launcher_missing_binary $binary
# CALLS: print_error
error_launcher_missing_binary() {
	local binary message
	binary="$1"
	case "${LANG%_*}" in
		('fr')
			message='Le fichier suivant est introuvable, mais la création dʼun lanceur pour celui-ci a été demandée : %s\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='The following file can not be found, but a launcher targeting it should have been created: %s\n'
			message="$message"'Please report this issue on our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$binary" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# display an error when the calling script does not set its target library version
# USAGE: error_missing_target_version
# CALLS: print_error
error_missing_target_version() {
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			string='Ce script ne donne aucune indication sur les versions de la bibliothèque ./play.it avec lesquelles il est compatible.\n'
			string="$string"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			string='This script gives no indication about its compatibility level with the ./play.it library.\n'
			string="$string"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	printf "$string" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# display an error when the calling script is not compatible with the provided library version
# USAGE: error_incompatible_versions
# CALLS: print_error
error_incompatible_versions() {
	local message
	case "${LANG%_*}" in
		('fr')
			message='Ce script nʼest pas compatible avec la version fournie de la bibliothèque ./play.it fournie.\n'
			message="$message"'La bibliothèque utilisée fournit actuellement la version %s, mais le script attend une version ≥ %s et < %s.\n'
		;;
		('en'|*)
			message='This script is not compatible with the ./play.it library version provided.\n'
			message="$message"'The library in use currently provides version %s, but the script expects a version ≥ %s and < %s.\n'
		;;
	esac
	print_error
	printf "$message" \
		"$VERSION_MAJOR_PROVIDED.$VERSION_MINOR_PROVIDED" \
		"$VERSION_MAJOR_TARGET.$VERSION_MINOR_TARGET" \
		"$((VERSION_MAJOR_TARGET + 1)).0"
	return 1
}

# display an error message if an icon dependency is missing
# USAGE: error_icon_dependency_not_found $dependency
# NEEDED VARS: (LANG)
# CALLED BY: check_deps
error_icon_dependency_not_found() {
	print_error
	case "${LANG%_*}" in
		('fr')
			string='%s est introuvable. Installez-le avant de lancer ce script.\n'
			string="$string"'Vous pouvez aussi utiliser --icons=no ou --icons=auto\n'
		;;
		('en'|*)
			string='%s not found. Install it before running this script.\n'
			string="$string"'You can also use --icons=no or --icons=auto\n'
		;;
	esac
	printf "$string" "$1"
	return 1
}

# display a warning message if an icon dependency is missing
# USAGE: warning_icon_dependency_not_found $dependency
# NEEDED VARS: (LANG)
# CALLED BY: check_deps
warning_icon_dependency_not_found() {
	print_warning
	case "${LANG%_*}" in
		('fr')
			string='%s est introuvable. Installez-le pour inclure les icônes.\n'
			string="$string"'Vous pouvez aussi utiliser --icons=no ou --icons=yes\n'
		;;
		('en'|*)
			string='%s not found. Install it to include icons.\n'
			string="$string"'You can also use --icons=no or --icons=yes\n'
		;;
	esac
	printf "$string\\n" "$1"
}

# display an error when the value assigned to a given option is not valid
# USAGE: error_option_invalid $option_name $option_value
error_option_invalid() {
	local message option_name option_value
	case "${LANG%_*}" in
		('fr')
			message='%s nʼest pas une valeur valide pour --%s.\n'
			message="$message"'Lancez le script avec lʼoption --%s=help pour une liste des valeurs acceptés.\n'
		;;
		('en'|*)
			message='%s is not a valid value for --%s.\n'
			message="$message"'Run the script with the option --%s=help to get a list of supported values.\n'
		;;
	esac
	print_error
	printf "$message" "$option_value" "$option_name"
	return 1
}

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

# display a list of archives, one per line, with their download URL if one is provided
# USAGE: information_archives_list $archive[…]
information_archives_list() {
	local archive archive_name archive_url
	for archive in "$@"; do
		archive_name="$(get_value "$archive")"
		archive_url="$(get_value "${archive}_URL")"
		if [ -n "$archive_url" ]; then
			printf '%s — %s\n' "$archive_name" "$archive_url"
		else
			printf '%s\n' "$archive_name"
		fi
	done
	return 0
}

# display an error message when a required archive is not found
# list all the archives that could fulfill the requirement, with their download URL if one is provided
# USAGE: error_archive_not_found $archive[…]
error_archive_not_found() {
	local message
	case "${LANG%_*}" in
		('fr')
			if [ $# -eq 1 ]; then
				message='Le fichier suivant est introuvable :\n'
			else
				message='Aucun des fichiers suivants nʼest présent :\n'
			fi
		;;
		('en'|*)
			if [ $# -eq 1 ]; then
				message='The following file could not be found:\n'
			else
				message='None of the following files could be found:\n'
			fi
		;;
	esac
	print_error
	printf "$message"
	information_archives_list "$@"
	return 1
}

# display an error message when we failed to guess the type of an archive
# USAGE: error_archive_type_not_set $archive
error_archive_type_not_set() {
	local message archive
	archive="$1"
	case "${LANG%_*}" in
		('fr')
			message='ARCHIVE_TYPE nʼest pas défini pour %s et nʼa pas pu être détecté automatiquement.\n'
		;;
		('en'|*)
			message='ARCHIVE_TYPE is not set for %s and could not be guessed.\n'
		;;
	esac
	print_error
	printf "$message" "$archive"
	return 1
}

# display the name of a file currently processed
# USAGE: information_file_in_use $file
information_file_in_use() {
	local message file
	file="$1"
	case "${LANG%_*}" in
		('fr')
			message='Utilisation de %s\n'
		;;
		('en'|*)
			message='Using %s\n'
		;;
	esac
	printf "$message" "$file"
	return 0
}

# display an error message when an integrity check fails
# USAGE: error_hashsum_mismatch $file
error_hashsum_mismatch() {
	local message file
	file=$(basename "$1")
	case "${LANG%_*}" in
		('fr')
			message='Somme de contrôle incohérente. %s nʼest pas le fichier attendu.\n'
			message="$message"'Utilisez --checksum=none pour forcer son utilisation.\n'
		;;
		('en'|*)
			message='Hashsum mismatch. %s is not the expected file.\n'
			message="$message"'Use --checksum=none to force its use.\n'
		;;
	esac
	print_error
	printf "$message" "$file"
	return 1
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

# display an error when the selected architecture is not supported
# USAGE: error_architecture_not_supported $architecture
error_architecture_not_supported() {
	local message architecture
	architecture="$1"
	case "${LANG%_*}" in
		('fr')
			message='Lʼarchitecture demandée nʼest pas gérée : %s\n'
		;;
		('en'|*)
			message='Selected architecture is not supported: %s\n'
		;;
	esac
	print_error
	printf "$message" "$architecture"
	return 1
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

# display an error when a variable required by the calling function is not set
# USAGE: error_variable_not_set $function $variable
error_variable_not_set() {
	local message function variable
	function="$1"
	variable="$2"
	case "${LANG%_*}" in
		('fr')
			message='La fonction "%s" ne peut pas être appelée lorsque "%s" nʼa pas de valeur définie.\n'
		;;
		('en'|*)
			message='"%s" function can not be called when "%s" is not set.\n'
		;;
	esac
	print_error
	printf "$message" "$function" "$variable"
	return 1
}

# display an error if there is not enough free storage space
# print a list of directories that have been scanned for available space
# USAGE: error_not_enough_free_space $directory[…]
error_not_enough_free_space() {
	local message directory
	case "${LANG%_*}" in
		('fr')
			message='Il nʼy a pas assez dʼespace libre dans les différents répertoires testés :\n'
		;;
		('en'|*)
			message='There is not enough free space in the tested directories:\n'
		;;
	esac
	print_error
	printf "$message"
	for directory in "$@"; do
		printf '%s\n' "$directory"
	done
	return 1
}

# print error when available version of innoextract is too old
# USAGE: error_innoextract_version_too_old $archive
error_innoextract_version_too_old() {
	local message archive
	archive="$1"
	case "${LANG%_*}" in
		('fr')
			message='La version de innoextract disponible sur ce système est trop ancienne pour extraire les données de lʼarchive suivante : %s\n'
		;;
		('en'|*)
			message='Available innoextract version is too old to extract data from the following archive: %s\n'
		;;
	esac
	print_error
	printf "$message" "$archive"
	return 1
}

# diplay an error message if an icon file can not be found
# USAGE: error_icon_file_not_found $file
error_icon_file_not_found() {
	local message file
	file="$1"
	case "${LANG%_*}" in
		('fr')
			message='Le fichier dʼicône suivant est introuvable : %s\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='The following icon file could not be found: %s\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$file" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# display a notification when trying to build a package that already exists
# USAGE: information_package_already_exists $file
information_package_already_exists() {
	local message file
	file="$1"
	case "${LANG%_*}" in
		('fr')
			message='%s existe déjà.\n'
		;;
		('en'|*)
			message='%s already exists.\n'
		;;
	esac
	printf "$message" "$file"
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

# display an error when called with an unknown option
# USAGE: error_option_unknown $option_name
error_option_unknown() {
	local message option_name
	option_name="$1"
	case "${LANG%_*}" in
		('fr')
			message='Option inconnue : %s\n'
		;;
		('en'|*)
			message='Unkown option: %s\n'
		;;
	esac
	print_error
	printf "$message" "$option_name"
	return 1
}

# display an error whent trying to set a compression method not compatible with the target package format
# USAGE: error_compression_method_not_compatible $compression_method $package_format
error_compression_method_not_compatible() {
	local message compression_method package_format
	compression_method="$1"
	package_format="$2"
	case "${LANG%_*}" in
		('fr')
			message='La méthode de compression "%s" nʼest pas compatible avec le format de paquets "%s".\n'
		;;
		('en'|*)
			message='"%s" compression method is not compatible with "%s" package format.\n'
		;;
	esac
	print_error
	printf "$message" "$compression_method" "$package_format"
	return 1
}

# display an error when a given path is not a directory
# USAGE: error_not_a_directory $path
error_not_a_directory() {
	local message path
	path="$1"
	case "${LANG%_*}" in
		('fr')
			message='"%s" nʼest pas un répertoire.\n'
		;;
		('en'|*)
			message='"%s" is not a directory.\n'
		;;
	esac
	print_error
	printf "$message" "$path"
	return 1
}

# display an error when a given path is not writable
# USAGE: error_not_writable $path
error_not_writable() {
	local message path
	path="$1"
	case "${LANG%_*}" in
		('fr')
			message='"%s" nʼest pas accessible en écriture.\n'
		;;
		('en'|*)
			message='"%s" is not writable.\n'
		;;
	esac
	print_error
	printf "$message" "$path"
	return 1
}

# display an error when a function has been given an unexpected empty string
# USAGE: error_empty_string $function $string
error_empty_string() {
	local message function string
	function="$1"
	string="$2"
	case "${LANG%_*}" in
		('fr')
			message='Lʼargument "%s" fourni à la fonction "%s" ne doit pas être vide.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='Argument "%s" as provided to function "%s" can not be empty.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$string" "$function" "$PLAYIT_BUG_TRACKER_URL"
	return 1
}

# display an error when a required command is missing, but a function was expecting it to be available
# USAGE: error_unavailable_command $function $command
error_unavailable_command() {
	local message function command
	function="$1"
	command="$2"
	case "${LANG%_*}" in
		('fr')
			message='La commande "%s" nʼest pas disponible, mais elle est requise par la fonction "%s".\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='"%s" command is not available, but it is required by function "%s".\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$command" "$function" "$PLAYIT_BUG_TRACKER_URL"
	return 1
}

