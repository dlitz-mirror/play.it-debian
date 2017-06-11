# display script usage
# USAGE: help
# NEEDED VARS: (LANG)
# CALLS: help_checksum help_compression help_prefix help_package
help() {
	local string
	local string_archive
	case "${LANG%_*}" in
		('fr')
			string='Utilisation :'
			string_archive='Ce script reconnaît l’archive suivante :'
			string_archives='Ce script reconnaît les archives suivantes :'
		;;
		('en'|*)
			string='Usage:'
			string_archive='This script can work on the following archive:'
			string_archives='This script can work on the following archives:'
		;;
	esac
	printf '\n'
	printf '%s %s [OPTION]… [ARCHIVE]\n\n' "$string" "${0##*/}"
	
	printf 'OPTIONS\n\n'
	help_checksum
	printf '\n'
	help_compression
	printf '\n'
	help_prefix
	printf '\n'
	help_package
	printf '\n'

	printf 'ARCHIVE\n\n'
	if [ ${ARCHIVE_LISTS##* *} ]; then
		printf '%s\n' "$string_archive"
	else
		printf '%s\n' "$string_archives"
	fi
	for archive in $ARCHIVES_LIST; do
		printf '%s\n' "$(eval printf -- '%b' \"\$$archive\")"
	done
	printf '\n'
}

# display --checksum option usage
# USAGE: help_checksum
# NEEDED VARS: (LANG)
# CALLED BY: help
help_checksum() {
	local string
	local string_md5
	local string_none
	case "${LANG%_*}" in
		('fr')
			string='Choix de la méthode de vérification d’intégrité de l’archive'
			string_md5='vérification via md5sum (méthode par défaut)'
			string_none='pas de vérification'
		;;
		('en'|*)
			string='Archive integrity verification method choice'
			string_md5='md5sum verification (default method)'
			string_none='no verification'
		;;
	esac
	printf -- '--checksum=md5|none\n'
	printf -- '--checksum md5|none\n\n'
	printf '\t%s\n\n' "$string"
	printf '\tmd5\t%s\n' "$string_md5"
	printf '\tnone\t%s\n' "$string_none"
}

# display --compression option usage
# USAGE: help_compression
# NEEDED VARS: (LANG)
# CALLED BY: help
help_compression() {
	local string
	local string_none
	local string_gzip
	local string_xz
	case "${LANG%_*}" in
		('fr')
			string='Choix de la méthode de compression des paquets générés'
			string_none='pas de compression (méthode par défaut)'
			string_gzip='compression gzip (rapide)'
			string_xz='compression xz (plus lent mais plus efficace que gzip)'
		;;
		('en'|*)
			string='Generated packages compression method choice'
			string_none='no compression (default method)'
			string_gzip='gzip compression (fast)'
			string_xz='xz compression (slower but more efficient than gzip)'
		;;
	esac
	printf -- '--compression=none|gzip|xz\n'
	printf -- '--compression none|gzip|xz\n\n'
	printf '\t%s\n\n' "$string"
	printf '\tnone\t%s\n' "$string_none"
	printf '\tgzip\t%s\n' "$string_gzip"
	printf '\txz\t%s\n' "$string_xz"
}

# display --prefix option usage
# USAGE: help_prefix
# NEEDED VARS: (LANG)
# CALLED BY: help
help_prefix() {
	local string
	local string_absolute
	local string_default
	case "${LANG%_*}" in
		('fr')
			string='Choix du chemin d’installation du jeu'
			string_absolute='Cette option accepte uniquement un chemin absolu.'
			string_default='chemin par défaut :'
		;;
		('en'|*)
			string='Game installation path choice'
			string_absolute='This option accepts an absolute path only.'
			string_default='default path:'
		;;
	esac
	printf -- '--prefix=$path\n'
	printf -- '--prefix $path\n\n'
	printf '\t%s\n\n' "$string"
	printf '\t%s\n' "$string_absolute"
	printf '\t%s /usr/local\n' "$string_default"
}

# display --package option usage
# USAGE: help_package
# NEEDED VARS: (LANG)
# CALLED BY: help
help_package() {
	local string
	local string_default
	local string_arch
	local string_deb
	case "${LANG%_*}" in
		('fr')
			string='Choix du type de paquet à construire'
			string_default='(type par défaut)'
			string_arch='paquet .pkg.tar (Arch Linux)'
			string_deb='paquet .deb (Debian, Ubuntu)'
		;;
		('en'|*)
			string='Generated package Type choice'
			string_default='(default type)'
			string_arch='.pkg.tar package (Arch Linux)'
			string_deb='.deb package (Debian, Ubuntu)'
		;;
	esac
	printf -- '--package=arch|deb\n'
	printf -- '--package arch|deb\n\n'
	printf '\t%s\n\n' "$string"
	printf '\tarch\t%s' "$string_arch"
	[ "$DEFAULT_OPTION_PACKAGE" = 'arch' ] && printf ' %s\n' "$string_default" || printf '\n'
	printf '\tdeb\t%s' "$string_deb"
	[ "$DEFAULT_OPTION_PACKAGE" = 'deb' ] && printf ' %s\n' "$string_default" || printf '\n'
}

