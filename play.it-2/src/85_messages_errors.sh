# display an error when a function has been called with an invalid argument
# USAGE: error_invalid_argument $var_name $calling_function
error_invalid_argument() {
	local var value func
	var="$1"
	value="$(get_value "$var")"
	func="$2"
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2059
	printf "$message" "$application_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
}

# display an error when the available tar implementation is not supported
# USAGE: error_unknown_tar_implementation
error_unknown_tar_implementation() {
	local message
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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
	return 1
}

# display an error when trying to extract an archive but no extractor is present
# USAGE: error_archive_no_extractor_found $archive_type
error_archive_no_extractor_found() {
	local message archive_type
	archive_type="$1"
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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

# display an error when the value assigned to a given option is not valid
# USAGE: error_option_invalid $option_name $option_value
error_option_invalid() {
	local message option_name option_value
	option_name="$1"
	option_value="$2"
	# shellcheck disable=SC2031
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
	printf "$message" "$option_value" "$option_name" "$option_name"
	return 1
}

# display an error when the compression method is not compatible with the
# package format
# USAGE: error_compression_invalid
error_compression_invalid() {
	local compression_method allowed_values package_format message

	compression_method="$OPTION_COMPRESSION"
	allowed_values="$ALLOWED_VALUES_COMPRESSION"
	package_format="$OPTION_PACKAGE"

	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La méthode de compression "%s" nʼest pas compatible avec le format de paquets "%s".\n'
			message="$message"'Seules les méthodes suivantes sont acceptées :\n'
			message="$message"'\t%s\n'
			;;
		('en'|*)
			message='"%s" compression method is not compatible with "%s" package format.\n'
			message="$message"'Only the following options are accepted:\n'
			message="$message"'\t%s\n'
			;;
	esac
	print_error
	# shellcheck disable=SC2059
	printf "$message" "$compression_method" "$package_format" "$allowed_values"
	return 1
}

# display an error message when a required archive is not found
# list all the archives that could fulfill the requirement, with their download URL if one is provided
# USAGE: error_archive_not_found $archive[…]
error_archive_not_found() {
	local message
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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

# display an error message when an integrity check fails
# USAGE: error_hashsum_mismatch $file
error_hashsum_mismatch() {
	local message file
	file=$(basename "$1")
	# shellcheck disable=SC2031
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

# display an error when the selected architecture is not supported
# USAGE: error_architecture_not_supported $architecture
error_architecture_not_supported() {
	local message architecture
	architecture="$1"
	# shellcheck disable=SC2031
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

# display an error when a variable required by the calling function is not set
# USAGE: error_variable_not_set $function $variable
error_variable_not_set() {
	local message function variable
	function="$1"
	variable="$2"
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La version de innoextract disponible sur ce système est trop ancienne pour extraire les données de lʼarchive suivante : %s\n'
			message="$message"'Des instructions de mise-à-jour sont proposées :\n'
			message="$message"'- pour Debian : %s\n'
			message="$message"'- pour Ubuntu : %s\n'
		;;
		('en'|*)
			message='Available innoextract version is too old to extract data from the following archive: %s\n'
			message="$message"'Update instructions are proposed:\n'
			message="$message"'- for Debian: %s\n'
			message="$message"'- for Ubuntu: %s\n'
		;;
	esac
	print_error
	printf "$message" "$archive" \
		'https://forge.dotslashplay.it/play.it/doc/-/wikis/distributions/debian#available-innoextract-version-is-too-old' \
		'https://forge.dotslashplay.it/play.it/doc/-/wikis/distributions/ubuntu#innoextract-version-is-too-old'
	return 1
}

# diplay an error message if an icon file can not be found
# USAGE: error_icon_file_not_found $file
error_icon_file_not_found() {
	local message file
	file="$1"
	# shellcheck disable=SC2031
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

# display an error when called with an unknown option
# USAGE: error_option_unknown $option_name
error_option_unknown() {
	local message option_name
	option_name="$1"
	# shellcheck disable=SC2031
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

# display an error when a given path is not a directory
# USAGE: error_not_a_directory $path
error_not_a_directory() {
	local message path
	path="$1"
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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
	# shellcheck disable=SC2031
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

# display an error when the calling script does not set its target library version
# USAGE: error_missing_target_version
# CALLS: print_error
error_missing_target_version() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Ce script ne donne aucune indication sur les versions de la bibliothèque ./play.it avec lesquelles il est compatible.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='This script gives no indication about its compatibility level with the ./play.it library.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# display an error when the calling script is not compatible with the provided library version
# USAGE: error_incompatible_versions
# CALLS: print_error
error_incompatible_versions() {
	local message
	# shellcheck disable=SC2031
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

# display an error when no game script has been found for a given archive
# USAGE: error_no_script_found_for_archive $archive
error_no_script_found_for_archive() {
	local message archive
	archive="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Impossible de trouver un script pour le fichier %s\n'
		;;
		('en'|*)
			message='Could not find script for file %s\n'
		;;
	esac
	print_error
	printf "$message" "$archive"
	return 1
}

# display an error when a variable is empty
# USAGE: error_empty_variable $variable
error_empty_variable() {
	local message variable
	variable="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La variable "%s" nʼest pas définie, mais elle requise.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='Variable "%s" is not set, but it is required.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$variable" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# display an error when trying to use a case-insensitive filesystem
# USAGE: error_case_insensitive_filesystem_is_not_supported $directory
error_case_insensitive_filesystem_is_not_supported() {
	local directory
	directory="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Ce répertoire se trouve sur un système de fichiers insensible à la casse : %s\n'
			message="$message"'Ce type de système de fichiers nʼest pas géré pour lʼopération demandée.\n'
		;;
		('en'|*)
			message='The following directory is on a case-insensitive filesystem: %s\n'
			message="$message"'Such filesystems are not supported for the current operation.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$directory"

	return 1
}

# display an error when trying to use a filesystem without support for UNIX permissions
# USAGE: error_unix_permissions_support_is_required $directory
error_unix_permissions_support_is_required() {
	local directory
	directory="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Ce répertoire se trouve sur un système de fichiers ne gérant pas les permissions UNIX : %s\n'
			message="$message"'Ce type de système de fichiers nʼest pas géré pour lʼopération demandée.\n'
		;;
		('en'|*)
			message='The following directory is on filesystem with no support for UNIX permissions: %s\n'
			message="$message"'Such filesystems are not supported for the current operation.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$directory"

	return 1
}

# display an error when trying to get the current archive but none is set
# USAGE: error_archive_unset
error_archive_unset() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Aucune archive nʼest définie, mais une est attendue à ce point de lʼexécution.\n'
		;;
		('en'|*)
			message='No archive is set, but one is expected at this step.\n'
		;;
	esac
	print_error
	# shellcheck disable=SC2059
	printf "$message"
	return 1
}

# display an error when trying to use an unkown type of context
# valid context types are:
# - archive
# - package
# USAGE: error_context_invalid $context
error_context_invalid() {
	local context
	context="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Un type de contexte inattendu a été demandé : %s\n'
			message="$message"'Seuls les types suivants sont valides :\n'
			message="$message"'\t- archive\n'
			message="$message"'\t- package\n'
		;;
		('en'|*)
			message='An unexpected context type has been required: %s\n'
			message="$message"'Only the following types are valid:\n'
			message="$message"'\t- archive\n'
			message="$message"'\t- package\n'
		;;
	esac
	print_error
	# shellcheck disable=SC2059
	printf "$message" "$context"
	return 1
}

# display an error when using an invalid format for an application id
# USAGE: error_application_id_invalid $application $application_id
error_application_id_invalid() {
	local application application_id
	application="$1"
	application_id="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼid fourni pour lʼapplication %s ne correspond pas au format attendu : "%s"\n'
			message="$message"'Cette valeur ne peut utiliser que des caractères du set [-a-z0-9],'
			message="$message"' et ne peut ni débuter ni sʼachever par un tiret.\n'
		;;
		('en')
			message='The id provided for application %s is not using the expected format: "%s"\n'
			message="$message"'The value should only include characters from the set [-a-z0-9],'
			message="$message"' and can not begin nor end with an hyphen.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$application" "$application_id"

	return 1
}

# display an error when using an invalid format for an application ScummVM id
# USAGE: error_application_scummid_invalid $application $application_scummid
error_application_scummid_invalid() {
	local application application_scummid
	application="$1"
	application_scummid="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼid ScummVM fourni pour lʼapplication %s ne semble pas correct : "%s"\n'
			message="$message"'Une liste de valeurs acceptées peut se trouver sur le site Web de ScummVM : \n%s\n'
		;;
		('en')
			message='The ScummVM id provided for application %s does not seem correct: "%s"\n'
			message="$message"'A list of valid values can be found on ScummVM website: \n%s\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" \
		"$application" \
		"$application_scummid" \
		'https://www.scummvm.org/compatibility/'

	return 1
}

# display an error when using an invalid format for an application ResidualVM id
# USAGE: error_application_residualid_invalid $application $application_residualid
error_application_residualid_invalid() {
	local application application_residualid
	application="$1"
	application_residualid="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Lʼid ResidualVM fourni pour lʼapplication %s ne semble pas correct : "%s"\n'
			message="$message"'Une liste de valeurs acceptées peut se trouver sur le site Web de ResidualVM : \n%s\n'
		;;
		('en')
			message='The ResidualVM id provided for application %s does not seem correct: "%s"\n'
			message="$message"'A list of valid values can be found on ResidualVM website: \n%s\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" \
		"$application" \
		"$application_residualid" \
		'https://www.residualvm.org/compatibility/'

	return 1
}

# display an error when APP_xxx_EXE is unset but the application requires it
# USAGE: error_application_exe_empty $application $application_type
error_application_exe_empty() {
	local application application_type
	application="$1"
	application_type="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='%s nʼest pas défini, mais cette valeur est requise pour les applications utilisant le type "%s".\n'
		;;
		('en')
			message='%s is not set, but is required for applications using "%" type.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "${application}_EXE" "$application_type"

	return 1
}

# display an error when a variable is spanning multiple lines
# USAGE: error_variable_multiline $variable_name
error_variable_multiline() {
	local variable_name
	variable_name="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La valeur %s sʼétend sur plusieurs lignes, ce qui nʼest pas autorisé.\n'
		;;
		('en')
			message='%s value is spanning multiple lines, but this is not allowed.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$variable_name"

	return 1
}

# display an error when calling a type-restricted function on the wrong application type
# USAGE: error_application_wrong_type $function_name $application_type
error_application_wrong_type() {
	local function_name application_type
	function_name="$1"
	application_type="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='%s ne peut pas être appelée sur les applications utilisant le type "%s".\n'
		;;
		('en')
			message='%s can not be called on applications using "%s" type.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$function_name" "$application_type"

	return 1
}

# displays an error when no valid candidates for ./play.it temporary directory
# has been found
# USAGE: error_no_valid_temp_dir_found $directory[…]
error_no_valid_temp_dir_found() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Aucun réportoire testé ne peut servir de répertoire
			temporaire pour ./play.it :\n'
		;;
		('en'|*)
			message='No tested repository can be used as ./play.it temporary
			directory:\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message"
	printf '%s\n' "$@"

	return 1
}

# display an error when the path to a given icon is unset but we try to use it
# USAGE: error_icon_path_empty $icon
error_icon_path_empty() {
	local icon
	icon="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='%s nʼest pas défini, mais il y a eu une tentative de récupérer le chemin de cette icône.\n'
		;;
		('en')
			message='%s is not set, but there has been a request for this icon path.\n'
		;;
	esac

	print_error
	# shellcheck disable=SC2059
	printf "$message" "$icon"

	return 1
}

