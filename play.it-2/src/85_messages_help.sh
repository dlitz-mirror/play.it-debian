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
	help_architecture
	help_checksum
	help_compression
	help_prefix
	help_package
	help_dryrun
	help_skipfreespacecheck
	help_icons
	help_overwrite
	help_output_dir

	# do not print a list of supported archives if called throught the "play.it" wrapper script
	if [ "$script_name" = 'play.it' ]; then
		return 0
	fi

	# print list of supported archives
	printf 'ARCHIVE\n\n'
	archives_get_list
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			if [ -n "${ARCHIVES_LIST##* *}" ]; then
				message='Ce script reconnaît lʼarchive suivante :\n'
			else
				message='Ce script reconnaît les archives suivantes :\n'
			fi
		;;
		('en'|*)
			if [ -n "${ARCHIVES_LIST##* *}" ]; then
				message='This script can work on the following archive:\n'
			else
				message='This script can work on the following archives:\n'
			fi
		;;
	esac
	printf "$message"
	information_archives_list $ARCHIVES_LIST

	return 0
}

# display --architecture option usage
# USAGE: help_architecture
help_architecture() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tChoix de lʼarchitecture à construire\n\n'
			message="$message"'\t%s\ttoutes les architectures disponibles\n'                        # all
			message="$message"'\t%s\tpaquets 32-bit seulement\n'                                    # 32
			message="$message"'\t%s\tpaquets 64-bit seulement\n'                                    # 64
			message="$message"'\t%s\tpaquets pour lʼarchitecture du système courant uniquement\n\n' # auto
		;;
		('en'|*)
			message='\tTarget architecture selection\n\n'
			message="$message"'\t%s\tall available architectures\n'                     # all
			message="$message"'\t%s\t32-bit packages only\n'                            # 32
			message="$message"'\t%s\t64-bit packages only\n'                            # 64
			message="$message"'\t%s\tpackages for current system architecture only\n\n' # auto
		;;
	esac
	printf -- '--architecture=all|32|64|auto\n'
	printf -- '--architecture all|32|64|auto\n\n'
	printf "$message" 'all' '32' '64' 'auto'
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
	return 0
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
			message="$message"'\t%s\tcompression lzip (similaire à xz)\n\n'
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
			message="$message"'\t%s\tlzip compression (similar to xz)\n\n'
		;;
	esac
	printf -- '--compression=none|gzip|xz|bzip2|zstd|lz4|lzip\n'
	printf -- '--compression none|gzip|xz|bzip2|zstd|lz4|lzip\n\n'
	printf "$message" 'none' 'gzip' 'xz' 'bzip2' 'zstd' 'lz4' 'lzip'
	return 0
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
	return 0
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
	return 0
}

# display --dry-run option usage
# USAGE: help_dryrun
help_dryrun() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tEffectue des tests de syntaxe mais nʼextrait pas de données et ne construit pas de paquets.\n\n'
		;;
		('en'|*)
			message='\tRun syntax checks but do not extract data nor build packages.\n\n'
		;;
	esac
	printf -- '--dry-run\n\n'
	printf "$message"
	return 0
}

# display --skip-free-space-check option usage
# USAGE: help_skipfreespacecheck
help_skipfreespacecheck() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tNe teste pas lʼespace libre disponible. Les répertoires temporaires seront créés sous $TMPDIR, ou /tmp par défaut.\n\n'
		;;
		('en'|*)
			message='\tDo not check for free space. Temporary directories are created under $TMPDIR, or /tmp by default.\n\n'
		;;
	esac
	printf -- '--skip-free-space-check\n\n'
	printf "$message"
	return 0
}

# display --icons option usage
# USAGE: help_icons
help_icons() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\tInclure ou non les icônes dans les paquets\n\n'
			message="$message"'\t%s\tInclure les icônes et sʼarrêter si une dépendance nʼa pas pu être trouvée\n' # yes
			message="$message"'\t%s\tNe pas inclure les icônes même si toutes les dépendances sont présentes\n'   # no
			message="$message"'\t%s\tInclure les icônes seulement si toutes les dépendances sont présentes\n\n'   # auto
		;;
		('en'|*)
			message='\tInclude icons in packages\n\n'
			message="$message"'\t%s\tInclude icons and stop if a dependency wasnʼt found\n'      # yes
			message="$message"'\t%s\tDonʼt include icons even if all dependencies are present\n' # no
			message="$message"'\t%s\tOnly include icons if all dependencies are present\n\n'     # auto
		;;
	esac
	printf -- '--icons=yes|no|auto\n'
	printf -- '--icons yes|no|auto\n\n'
	printf "$message" 'yes' 'no' 'auto'
	return 0
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
	return 0
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
	return 0
}

