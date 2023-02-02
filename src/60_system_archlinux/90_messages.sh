# print mtree computation message
# USAGE: info_package_mtree_computation $package
info_package_mtree_computation() {
	local package
	package="$1"

	local package_name
	package_name=$(package_path "$package")

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Création du fichier .MTREE pour %s…\n'
			;;
		('en'|*)
			message='Creating .MTREE file for %s…\n'
			;;
	esac
	printf "$message" "$package_name"
}
