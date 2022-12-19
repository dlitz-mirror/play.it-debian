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

# display an error when a function has been called without arguments
# USAGE: error_no_arguments $called_function
error_no_arguments() {
	local called_function="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='%s ne peut pas être appelée sans arguments.\n'
			;;
		('en'|*)
			message='%s can not be called without arguments.\n'
			;;
	esac
	print_error
	printf "$message" "$called_function"
}

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
}

# display an error when a function has been given an unexpected empty string
# USAGE: error_empty_string $calling_function $variable_name
error_empty_string() {
	local calling_function variable_name
	calling_function="$1"
	variable_name="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La variable "%s" de la fonction "%s" ne doit pas être vide.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='Variable "%s" in function "%s" can not be empty.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$variable_name" "$calling_function" "$PLAYIT_BUG_TRACKER_URL"
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
}

# displays an error when no valid candidates for ./play.it temporary directory
# has been found
# USAGE: error_no_valid_temp_dir_found $directory[…]
error_no_valid_temp_dir_found() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Aucun répertoire testé ne peut servir de répertoire
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
}

# Display an error when trying to use a non-existing directory for temporary files
# USAGE: error_temporary_path_not_a_directory $temporary_directory_path
error_temporary_path_not_a_directory() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le chemin demandé pour stocker les fichiers temporaires nʼexiste pas'
			message="$message"', ou nʼest pas un répertoire : %s\n'
			message="$message"'Un chemin alternatif peut-être fourni avec --tmpdir.\n'
		;;
		('en'|*)
			message='The path set for temporary files storage does not exist'
			message="$message"', or is not a directory: %s\n'
			message="$message"'An alternative path can be provided with --tmpdir.\n'
		;;
	esac

	print_error
	printf "$message" "$temporary_directory_path"
}

# Display an error when trying to use a directory with no write access for temporary files
# USAGE: error_temporary_path_not_writable $temporary_directory_path
error_temporary_path_not_writable() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le chemin demandé pour stocker les fichiers temporaires nʼest pas accessible en écriture : %s\n'
			message="$message"'Un chemin alternatif peut-être fourni avec --tmpdir.\n'
		;;
		('en'|*)
			message='The path set for temporary files storage has no write access: %s\n'
			message="$message"'An alternative path can be provided with --tmpdir.\n'
		;;
	esac

	print_error
	printf "$message" "$temporary_directory_path"
}

# Display an error when trying to use a directory on a case-insensitive file system for temporary files
# USAGE: error_temporary_path_not_case_sensitive $temporary_directory_path
error_temporary_path_not_case_sensitive() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le chemin demandé pour stocker les fichiers temporaires est sur un système de fichiers qui nʼest pas sensible à la casse des noms de fichiers : %s\n'
			message="$message"'Un chemin alternatif peut-être fourni avec --tmpdir.\n'
		;;
		('en'|*)
			message='The path set for temporary files storage is on a case-insensitive file system: %s\n'
			message="$message"'An alternative path can be provided with --tmpdir.\n'
		;;
	esac

	print_error
	printf "$message" "$temporary_directory_path"
}

# Display an error when trying to use a directory for temporary files that has no support for UNIX permissions
# USAGE: error_temporary_path_no_unix_permissions $temporary_directory_path
error_temporary_path_no_unix_permissions() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le chemin demandé pour stocker les fichiers temporaires ne prend pas en charge les permissions UNIX : %s\n'
			message="$message"'Un chemin alternatif peut-être fourni avec --tmpdir.\n'
		;;
		('en'|*)
			message='The path set for temporary files storage has no support for UNIX permissions: %s\n'
			message="$message"'An alternative path can be provided with --tmpdir.\n'
		;;
	esac

	print_error
	printf "$message" "$temporary_directory_path"
}

# Display an error when trying to use a directory for temporary files that is mounted with noexec
# USAGE: error_temporary_path_noexec $temporary_directory_path
error_temporary_path_noexec() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le chemin demandé pour stocker les fichiers temporaires ne permet pas la création de fichiers exécutables : %s\n'
			message="$message"'Un chemin alternatif peut-être fourni avec --tmpdir.\n'
		;;
		('en'|*)
			message='The path set for temporary files storage forbid the creation of executable files: %s\n'
			message="$message"'An alternative path can be provided with --tmpdir.\n'
		;;
	esac

	print_error
	printf "$message" "$temporary_directory_path"
}

# Display an error when trying to use a directory with not enough free space for temporary files
# USAGE: error_temporary_path_not_enough_space $temporary_directory_path
error_temporary_path_not_enough_space() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Le chemin demandé pour stocker les fichiers temporaires ne dispose pas dʼassez dʼespace libre : %s\n'
			message="$message"'Un chemin alternatif peut-être fourni avec --tmpdir.\n'
			message="$message"'Cette vérification de lʼespace libre peut aussi être contournée avec --skip-free-space-check.\n'
		;;
		('en'|*)
			message='The path set for temporary files storage has not enough free space: %s\n'
			message="$message"'An alternative path can be provided with --tmpdir.\n'
			message="$message"'This free space check can also be disabled using --skip-free-space-check.\n'
		;;
	esac

	print_error
	printf "$message" "$temporary_directory_path"
}

# Display an error when trying to get the value of an unset variable.
# USAGE: error_variable_not_set $variable_name
error_variable_not_set() {
	local variable_name
	variable_name="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La valeur de la variable suivante a été demandée, mais elle nʼa pas été définie : %s\n'
		;;
		('en'|*)
			message='The value of the following variable has been queried, but it has not been set: %s\n'
		;;
	esac

	print_error
	printf "$message" "$variable_name"
}
