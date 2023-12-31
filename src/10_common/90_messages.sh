# Print a localized error message
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
	## This will mess with output redirections from game scripts
	## if it is not called from a subshell.
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

# Information - All the packages are already built, there is no need to run a new build
# USAGE: info_all_packages_already_built
info_all_packages_already_built() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Tous les paquets sont déjà présents, il nʼy a pas besoin de les reconstruire.\n'
		;;
		('en'|*)
			message='All the packages are already built, there is no need to run a new build.\n'
		;;
	esac

	printf "$message"
}

# Display a warning when a deprecated function is called.
# USAGE: warning_deprecated_function $old_function $new_function
warning_deprecated_function() {
	local old_function new_function
	old_function="$1"
	new_function="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La fonction suivante est dépréciée : %s\n'
			message="$message"'Cette nouvelle fonction devrait être utilisée à sa place : %s\n\n'
		;;
		('en'|*)
			message='The following function is deprecated: %s\n'
			message="$message"'This new function should be used instead: %s\n\n'
		;;
	esac

	# Print the message on the standard error output,
	# to avoid messing up the regular output of the function that triggered this warning.
	print_warning > /dev/stderr
	printf "$message" "$old_function" "$new_function" > /dev/stderr
}

# Display a warning when a deprecated variable is set.
# USAGE: warning_deprecated_variable $old_variable $new_variable
warning_deprecated_variable() {
	local old_variable new_variable
	old_variable="$1"
	new_variable="$2"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La variable suivante est dépréciée : %s\n'
			message="$message"'Cette nouvelle variable devrait être utilisée à sa place : %s\n\n'
		;;
		('en'|*)
			message='The following variable is deprecated: %s\n'
			message="$message"'This new variable should be used instead: %s\n\n'
		;;
	esac

	# Print the message on the standard error output,
	# to avoid messing up the regular output of the variable that triggered this warning.
	print_warning > /dev/stderr
	printf "$message" "$old_variable" "$new_variable" > /dev/stderr
}

# Error - The given path is not a file
# USAGE: error_not_a_file $path
error_not_a_file() {
	local path
	path="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='"%s" nʼest pas un fichier valide.\n'
		;;
		('en'|*)
			message='"%s" is not a valid file.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$path"
	)
}

# Error - The available tar implementation is not supported
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
	(
		print_error
		printf "$message" "$PLAYIT_BUG_TRACKER_URL"
	)
}

# Error - The given path is not a directory
# USAGE: error_not_a_directory $path
error_not_a_directory() {
	local path
	path="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='"%s" nʼest pas un répertoire.\n'
		;;
		('en'|*)
			message='"%s" is not a directory.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$path"
	)
}

# Error - The given path is not writable
# USAGE: error_not_writable $path
error_not_writable() {
	local path
	path="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='"%s" nʼest pas accessible en écriture.\n'
		;;
		('en'|*)
			message='"%s" is not writable.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$path"
	)
}

# Error - The function has been given an unexpected empty string
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
	(
		print_error
		printf "$message" "$variable_name" "$calling_function" "$PLAYIT_BUG_TRACKER_URL"
	)
}

# Error - A required command is missing
# USAGE: error_unavailable_command $function $required_command
error_unavailable_command() {
	local function required_command
	function="$1"
	required_command="$2"

	local message
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
	(
		print_error
		printf "$message" "$required_command" "$function" "$PLAYIT_BUG_TRACKER_URL"
	)
}

# Error - The target library version is not set
# USAGE: error_missing_target_version
error_missing_target_version() {
	local message
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
	(
		print_error
		printf "$message" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	)
}

# Error - The calling script is not compatible with the provided library version
# USAGE: error_incompatible_versions
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
	(
		print_error
		printf "$message" \
			"${VERSION_MAJOR_PROVIDED}.${VERSION_MINOR_PROVIDED}" \
			"${VERSION_MAJOR_TARGET}.${VERSION_MINOR_TARGET}" \
			"$((VERSION_MAJOR_TARGET + 1)).0"
	)
}

# Error - The wrapper has been called with no archive argument
# USAGE: error_archive_missing_from_arguments
error_archive_missing_from_arguments() {
	local message
	case "${LANG%_*}" in
		('fr')
			message='Aucune archive nʼa été fournie sur la ligne de commande.\n'
		;;
		('en'|*)
			message='No archive has been provided on the command line.\n'
		;;
	esac
	(
		print_error
		printf "$message"
	)
}

# Error - No game script has been found for the given archive
# USAGE: error_no_script_found_for_archive $archive
error_no_script_found_for_archive() {
	local archive
	archive="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Impossible de trouver un script pour le fichier %s\n'
		;;
		('en'|*)
			message='Could not find script for file %s\n'
		;;
	esac
	(
		print_error
		printf "$message" "$archive"
	)
}

# Error - A variable is spanning multiple lines
# USAGE: error_variable_multiline $variable_name
error_variable_multiline() {
	local variable_name
	variable_name="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='La valeur %s sʼétend sur plusieurs lignes, ce qui nʼest pas autorisé.\n'
		;;
		('en')
			message='%s value is spanning multiple lines, but this is not allowed.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$variable_name"
	)
}

# Error - A type-restricted function has been called on the wrong application type
# USAGE: error_application_wrong_type $function_name $application_type
error_application_wrong_type() {
	local function_name application_type
	function_name="$1"
	application_type="$2"

	local message
	case "${LANG%_*}" in
		('fr')
			message='%s ne peut pas être appelée sur les applications utilisant le type "%s".\n'
		;;
		('en')
			message='%s can not be called on applications using "%s" type.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$function_name" "$application_type"
	)
}

# Error - The directory for temporary files storage does not exist
# USAGE: error_temporary_path_not_a_directory $temporary_directory_path
error_temporary_path_not_a_directory() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
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
	(
		print_error
		printf "$message" "$temporary_directory_path"
	)
}

# Error - The directory for temporary files storage has no write access
# USAGE: error_temporary_path_not_writable $temporary_directory_path
error_temporary_path_not_writable() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
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
	(
		print_error
		printf "$message" "$temporary_directory_path"
	)
}

# Error - The directory for temporary files storage is not case-sensitive
# USAGE: error_temporary_path_not_case_sensitive $temporary_directory_path
error_temporary_path_not_case_sensitive() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
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
	(
		print_error
		printf "$message" "$temporary_directory_path"
	)
}

# Error - The directory for temporary files storage has no support for UNIX permissions
# USAGE: error_temporary_path_no_unix_permissions $temporary_directory_path
error_temporary_path_no_unix_permissions() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
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
	(
		print_error
		printf "$message" "$temporary_directory_path"
	)
}

# Error - The directory for temporary files storage is mounted with noexec
# USAGE: error_temporary_path_noexec $temporary_directory_path
error_temporary_path_noexec() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
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
	(
		print_error
		printf "$message" "$temporary_directory_path"
	)
}

# Error - There is not enough free space in the directory for temporary files storage
# USAGE: error_temporary_path_not_enough_space $temporary_directory_path
error_temporary_path_not_enough_space() {
	local temporary_directory_path
	temporary_directory_path="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Le chemin demandé pour stocker les fichiers temporaires ne dispose pas dʼassez dʼespace libre : %s\n'
			message="$message"'Un chemin alternatif peut-être fourni avec --tmpdir.\n'
			message="$message"'Cette vérification de lʼespace libre peut aussi être contournée avec --no-free-space-check.\n'
		;;
		('en'|*)
			message='The path set for temporary files storage has not enough free space: %s\n'
			message="$message"'An alternative path can be provided with --tmpdir.\n'
			message="$message"'This free space check can also be disabled using --no-free-space-check.\n'
		;;
	esac
	(
		print_error
		printf "$message" "$temporary_directory_path"
	)
}

# Error - A mandatory variable is not set
# USAGE: error_missing_variable $variable_name
error_missing_variable() {
	local variable_name
	variable_name="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='La variable suivante est requise, mais elle nʼa pas été définie ou sa valeur est nulle : %s\n'
		;;
		('en'|*)
			message='The following variable is mandatory, but it is unset or its value is null: %s\n'
		;;
	esac

	(
		print_error
		printf "$message" "$variable_name"
	)
}

