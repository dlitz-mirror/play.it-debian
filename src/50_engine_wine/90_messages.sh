# Display an error when trying to set WINE Direct3D renderer to an unsupported value
# USAGE: error_unknown_wine_renderer $unknown_value
error_unknown_wine_renderer() {
	local unknown_value
	unknown_value="$1"

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='La valeur suivante est invalide pour WINE_DIRECT3D_RENDERER : %s\n'
		;;
		('en'|*)
			message='The following value is not supported for WINE_DIRECT3D_RENDERER: %s\n'
		;;
	esac

	print_error
	printf "$message" "$unknown_value"
}
