# display a warning when using a library not available on target system in a
# given architecture
# USAGE: warning_missing_library $lib $target_system $architecture
warning_missing_library() {
	local lib
	local target_system
	local architecture
	lib="$1"
	target_system="$2"
	architecture="$3"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La bibliothèque %s nʼest pas disponible pour %s (architecture %s).\n'
		;;
		('en'|*)
			message='The library %s is not available on %s (%s architecture).\n'
		;;
	esac
	print_warning
	printf "$message" "$lib" "$target_system" "$architecture"
}

# print mtree computation message
# USAGE: info_package_mtree_computation $package
info_package_mtree_computation() {
	local pkg pkg_name message
	pkg="$1"
	pkg_name="$(package_get_name "$pkg")"
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Création du fichier .MTREE pour %s…\n'
			;;
		('en'|*)
			message='Creating .MTREE file for %s…\n'
			;;
	esac
	# shellcheck disable=SC2059
	printf "$message" "$pkg_name"
}

# print mtree computation success message
# USAGE: info_package_mtree_computation_done
info_package_mtree_computation_done() {
	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Fichier .MTREE créé !'
			;;
		('en'|*)
			message='.MTREE file created!'
			;;
	esac
	printf '%s\n' "$message"
}

