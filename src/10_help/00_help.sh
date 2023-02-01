# display full usage instructions
# USAGE: help
help() {
	local message script_name
	script_name=$(basename "$0")

	# print general usage instructions
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			if [ "$script_name" = 'play.it' ]; then
				message='\nUtilisation : %s ARCHIVE [OPTION]…\n\n'
			else
				message='\nUtilisation : %s [OPTION]… [ARCHIVE]\n\n'
			fi
		;;
		('en'|*)
			if [ "$script_name" = 'play.it' ]; then
				message='\nUsage: %s ARCHIVE [OPTION]…\n\n'
			else
				message='\nUsage: %s [OPTION]… [ARCHIVE]\n\n'
			fi
		;;
	esac
	printf "$message" "$script_name"

	# print details about options usage
	printf 'OPTIONS\n\n'
	help_checksum
	help_compression
	help_prefix
	help_package
	help_icons
	help_overwrite
	help_output_dir
	help_debug
	help_no_mtree
	help_tmpdir
	help_skipfreespacecheck
	help_configfile
	help_listpackages
	help_listrequirements

	# do not print a list of supported archives if called throught the "play.it" wrapper script
	if [ "$script_name" = 'play.it' ]; then
		help_show_game_script
		return 0
	fi

	# print list of supported archives
	printf 'ARCHIVE\n\n'
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Ce script reconnaît les archives suivantes :'
		;;
		('en'|*)
			message='This script can work on the following archives:'
		;;
	esac
	printf '%s\n' "$message"
	# shellcheck disable=SC2046
	information_archives_list $(archives_return_list)

	return 0
}

# display --checksum option usage
# USAGE: help_checksum
help_checksum() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tChoix de la méthode de vérification dʼintégrité de lʼarchive\n\n'
			message="$message"'\t%s\tvérification via md5sum\n' # md5
			message="$message"'\t%s\tpas de vérification\n\n'   # none
		;;
		('en'|*)
			message='\tArchive integrity verification method selection\n\n'
			message="$message"'\t%s\tmd5sum verification\n' # md5
			message="$message"'\t%s\tno verification\n\n'   # none
		;;
	esac
	printf -- '--checksum=md5|none\n'
	printf -- '--checksum md5|none\n\n'
	printf "$message" 'md5' 'none'
}

# display --compression option usage
# CALLED BY: help
help_compression() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tChoix de la méthode de compression des paquets générés\n'
			message="$message"'(Certaines options peuvent ne pas être disponible suivant le format de paquet choisi.)\n\n'
			message="$message"'\t%s\tpas de compression\n'
			message="$message"'\t%s\tcompression gzip (rapide)\n'
			message="$message"'\t%s\tcompression xz (plus lent mais plus efficace que gzip)\n'
			message="$message"'\t%s\tcompression bzip2\n'
			message="$message"'\t%s\tcompression zstd\n'
			message="$message"'\t%s\tcompression lz4 (le plus rapide, mais le plus lourd)\n'
			message="$message"'\t%s\tcompression lzip (similaire à xz)\n'
			message="$message"'\t%s\tcompression lzop (plus lent que lz4 à décompresser mais plus efficace)\n\n'
		;;
		('en'|*)
			message='\tGenerated packages compression method selection\n'
			message="$message"'(Some options may not be available depending on the chosen package format.)\n\n'
			message="$message"'\t%s\tno compression\n'
			message="$message"'\t%s\tgzip compression (fast)\n'
			message="$message"'\t%s\txz compression (slower but more efficient than gzip)\n'
			message="$message"'\t%s\tbzip2 compression\n'
			message="$message"'\t%s\tzstd compression\n'
			message="$message"'\t%s\tlz4 compression (fastest but biggest files)\n'
			message="$message"'\t%s\tlzip compression (similar to xz)\n'
			message="$message"'\t%s\tlzop compression (slower than lz4 at inflating but more efficient)\n\n'
		;;
	esac
	printf -- '--compression=none|gzip|xz|bzip2|zstd|lz4|lzip|lzop\n'
	printf -- '--compression none|gzip|xz|bzip2|zstd|lz4|lzip|lzop\n\n'
	# shellcheck disable=SC2059
	printf "$message" 'none' 'gzip' 'xz' 'bzip2' 'zstd' 'lz4' 'lzip' 'lzop'
}

# display --prefix option usage
# USAGE: help_prefix
help_prefix() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tChoix du chemin dʼinstallation du jeu\n\n'
			message="$message"'\tCette option accepte uniquement un chemin absolu.\n\n'
		;;
		('en'|*)
			message='\tGame installation path setting\n\n'
			message="$message"'\tThis option accepts an absolute path only.\n\n'
		;;
	esac
	printf -- '--prefix=$path\n'
	printf -- '--prefix $path\n\n'
	printf "$message"
}

# display --package option usage
# USAGE: help_package
help_package() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tChoix du type de paquet à construire\n\n'
			message="$message"'\t%s\tpaquet .pkg.tar (Arch Linux)\n' # arch
			message="$message"'\t%s\tpaquet .deb (Debian, Ubuntu)\n' # deb
			message="$message"'\t%s\tpaquet .tbz2 (Gentoo)\n\n'      # gentoo
		;;
		('en'|*)
			message='\tGenerated package type selection\n\n'
			message="$message"'\t%s\t.pkg.tar package (Arch Linux)\n' # arch
			message="$message"'\t%s\t.deb package (Debian, Ubuntu)\n' # deb
			message="$message"'\t%s\t.tbz2 package (Gentoo)\n\n'      #gentoo
		;;
	esac
	printf -- '--package=arch|deb|gentoo\n'
	printf -- '--package arch|deb|gentoo\n\n'
	printf "$message" 'arch' 'deb' 'gentoo'
}

# display --no-icons option usage
# USAGE: help_icons
help_icons() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tNe pas inclure les icônes du jeu.\n\n'
		;;
		('en'|*)
			message='\tDo not include game icons.\n\n'
		;;
	esac
	printf -- '--no-icons\n\n'
	printf "$message"
}

# display --overwrite option usage
# USAGE: help_overwrite
help_overwrite() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tRemplace les paquets si ils existent déjà.\n\n'
		;;
		('en'|*)
			message='\tReplace packages if they already exist.\n\n'
		;;
	esac
	printf -- '--overwrite\n\n'
	printf "$message"
}

# display --output-dir option usage
# USAGE: help_output_dir
help_output_dir() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tDéfinit le répertoire de destination des paquets générés.\n\n'
		;;
		('en'|*)
			message='\tSet the output directory for generated packages.\n\n'
		;;
	esac
	printf -- '--output-dir\n\n'
	printf "$message"
}

# display --debug option usage
# USAGE: help_debug
help_debug() {
	local message

	# shellcheck disable=SC2050
	if [ %%DEBUG_DISABLED%% -eq 1 ]; then
		#shellcheck disable=SC2031
		case "${LANG%_*}" in
			('fr')
				message='\tLe debug a été désactivé lors de la compilation.\n'
				message="$message"'\tCette option est sans effet.\n\n'
				;;
			('en'|*)
				message='\tDebug was disabled at compile-time.\n'
				message="$message"'\tThis option has no effect.\n\n'
				;;
		esac
	else
		#shellcheck disable=SC2031
		case "${LANG%_*}" in
			('fr')
				message='\tDéfinit le niveau de debug. Il vaut 1 par défaut.\n\n'
				;;
			('en'|*)
				message='\tSet the debug level. Default is 1.\n\n'
				;;
		esac
	fi

	printf -- '--debug\n'
	printf -- '--debug=N\n'
	printf -- '--debug N\n\n'
	printf "$message"
}

# display --show-game-script option usage
# USAGE: help_show_game_script
help_show_game_script() {
	local message

	#shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tAffiche uniquement le chemin vers le script à utiliser, sans le lancer.\n\n'
			;;
		('en'|*)
			message='\tOnly displays the name of the script to use, without running it.\n\n'
			;;
	esac

	printf -- '--show-game-script\n'
	printf "$message"
}

# display --no-mtree option usage
# USAGE: help_no_mtree
help_no_mtree() {
	local message

	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tNe crée pas de fichier .MTREE pour les paquets Arch Linux.\n\n'
			;;
		('en'|*)
			message='\tDo not make .MTREE file in Arch Linux packages\n\n'
			;;
	esac

	printf -- '--no-mtree\n'
	printf "$message"
}

# Display --tmpdir option usage
# USAGE: help_tmpdir
help_tmpdir() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tDéfinit le répertoire utilisé pour le stockage des fichiers temporaire.\n'
			message="$message"'\tLa valeur par défaut est : %s\n\n'
		;;
		('en'|*)
			message='\tSet the directory used for temporary files storage.\n'
			message="$message"'\tDefault value is: %s\n\n'
		;;
	esac
	printf -- '--tmpdir\n\n'
	local default_value
	default_value=$(option_value_default 'tmpdir')
	printf "$message" "$default_value"
}

# Display --no-free-space-check option usage
# USAGE: help_skipfreespacecheck
help_skipfreespacecheck() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tNe pas tester lʼespace libre disponible.\n\n'
		;;
		('en'|*)
			message='\tDo not check for free space.\n\n'
		;;
	esac
	printf -- '--no-free-space-check\n\n'
	printf "$message"
}

# Display --config-file option usage
# USAGE: help_configfile
help_configfile() {
	local config_file_path
	config_file_path=$(configuration_file_default_path)

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tDéfinit le fichier de configuration à utiliser.\n'
			message="$message"'\tLe fichier par défaut est : %s\n\n'
			;;
		('en'|*)
			message='\tSet the configuration file to use.\n'
			message="$message"'\tDefault file is: %s\n\n'
			;;
	esac
	printf -- '--config-file\n\n'
	printf "$message" "$config_file_path"
}

# Display --list-packages option usage
# USAGE: help_listpackages
help_listpackages() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tAffiche la liste des paquets à construire.\n\n'
			;;
		('en'|*)
			message='\tPrint the list of packages to build.\n\n'
			;;
	esac
	printf -- '--list-packages\n\n'
	printf "$message"
}

# Display --list-requirements option usage
# USAGE: help_listrequirements
help_listrequirements() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tAffiche la liste des commandes nécessaire à la construction de paquets à partir de lʼarchive donnée.\n\n'
		;;
		('en'|*)
			message='\tPrint the list of commands required to build packages from the given archive.\n\n'
		;;
	esac
	printf -- '--list-requirements\n\n'
	printf "$message"
}
