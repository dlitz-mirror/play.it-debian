# Error - The DOSBox image disk was not found
# USAGE: error_dosbox_disk_image_no_found $disk_image
error_dosbox_disk_image_no_found() {
	local disk_image
	disk_image="$1"

	local message
	case "${LANG%_*}" in
		('fr')
			message='Lʼimage de disque suivante nʼa pas été trouvée : %s\n'
		;;
		('en'|*)
			message='The following disk image could not be found: %s\n'
		;;
	esac
	(
		print_error
		printf "$message" "$disk_image"
	)
}

