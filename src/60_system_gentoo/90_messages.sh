# print notification about required overlays when building Gentoo packages
# USAGE: information_required_gentoo_overlays $overlays
information_required_gentoo_overlays() {
	local message overlays
	overlays="$1"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\nVous pouvez avoir besoin des overlays suivants pour installer ces paquets : %s\n'
		;;
		('en'|*)
			message='\nYou may need the following overlays to install these packages: %s\n'
		;;
	esac
	printf "$message" "$overlays"
}

# add comment to packages installation instructions on Gentoo
# USAGE: information_installation_instructions_gentoo_comment
information_installation_instructions_gentoo_comment() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='ou mettez les paquets dans un PKGDIR (dans un dossier nommé games-playit) et emergez-les'
		;;
		('en'|*)
			message='or put the packages in a PKGDIR (in a folder named games-playit) and emerge them'
		;;
	esac
	printf "$message"
}

# inform the need of a local overlay on gentoo for ebuilds
# USAGE: info_local_overlay_gentoo
info_local_overlay_gentoo() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='\nUn overlay local est nécessaire pour utiliser les ebuilds générés par ./play.it\n'
			message="$message"'Dans la suite OVERLAY_PATH correspond au chemin de votre overlay local\n'
		;;
		('en'|*)
			message='\nA local overlay is needed to use the ebuilds generated by ./play.it\n'
			message="$message"'In what comes next, OVERLAY_PATH is the path to your local overlay\n'
		;;
	esac
	# shellcheck disable=SC2059
	printf "$message"
}

# inform the need to move the packages to a distfile on egentoo
# USAGE: info_package_to_distfiles
info_package_to_distfiles() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Déplacez les paquets créés dans votre disfile\n'
			message="$message"'puis exécutez les instructions suivantes :\n'
			;;
		('en'|*)
			message='Move the generated packages into your distfile\n'
			message="$message"'then run the following commands:\n'
			;;
	esac
	# shellcheck disable=SC2059
	printf "$message"
}

