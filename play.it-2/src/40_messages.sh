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

# display an error if a file is expected and something else has been given
# USAGE: error_not_a_file $param
# CALLS: print_error
error_not_a_file() {
	if [ $# -lt 1 ]; then
		error_missing_argument 'error_not_a_file'
	fi
	if [ $# -gt 1 ]; then
		error_extra_arguments 'error_not_a_file'
	fi
	local param
	param="$1"
	print_error
	case "${LANG%_*}" in
		('fr')
			string='"%s" nʼest pas un fichier valide.\n'
		;;
		('en'|*)
			string='"%s" is not a valid file.\n'
		;;
	esac
	printf "$string" "$param"
	exit 1
}

# display an error when an unknown application type is used
# USAGE: error_unknown_application_type $app_type
# CALLS: print_error
error_unknown_application_type() {
	local application_type
	application_type="$1"
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			string='Le type dʼapplication "%s" est inconnu.\n'
			string="$string"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			string='"%s" application type is unknown.\n'
			string="$string"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	printf "$string" "$application_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	exit 1
}

# display an error when the tar implementation isn’t recognized
# USAGE: error_unknown_tar_implementation
# CALLS: print_error
error_unknown_tar_implementation() {
	local string
	print_error
	case "${LANG%_*}" in
		('fr')
			string='La version de tar présente sur ce système nʼest pas reconnue.\n'
			string="$string"'./play.it ne peut utiliser que GNU tar ou bsdtar.\n'
			string="$string"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			string='The tar implementation on this system wasnʼt recognized.\n'
			string="$string"'./play.it can only use GNU tar or bsdtar.\n'
			string="$string"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	printf "$string" "$PLAYIT_BUG_TRACKER_URL"
	exit 1
}

# display a message if a required dependency is missing
# USAGE: error_dependency_not_found $command_name
# CALLED BY: check_deps check_deps_7z
# CALLS: dependency_provided_by
error_dependency_not_found() {
	local command_name provider
	command_name="$1"
	provider="$(dependency_provided_by "$command_name")"
	print_error
	case "${LANG%_*}" in
		('fr')
			string='%s est introuvable. Installez %s avant de lancer ce script.\n'
		;;
		('en'|*)
			string='%s not found. Install %s before running this script.\n'
		;;
	esac
	printf "$string" "$command_name" "$provider"
	return 1
}

# display an error when trying to extract an archive but no extractor is present
# USAGE: error_archive_no_extractor_found $archive_type
# CALLS: print_error
error_archive_no_extractor_found() {
	local archive_type string
	archive_type="$1"
	print_error
	case "${LANG%_*}" in
		('fr')
			string='Ce script a essayé dʼextraire le contenu dʼune archive de type "%s", mais aucun outil approprié nʼa été trouvé.\n'
			string="$string"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			string='This script tried to extract the contents of a "%s" archive, but not appropriate tool could be found.\n'
			string="$string"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	printf "$string" "$archive_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	exit 1
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

