# compute the icon path from the UNITY3D_NAME value
# USAGE: icon_unity3d_path $icon
# RETURN: the icon path, it can include spaces,
#         or an empty string
icon_unity3d_path() {
	# Check that the application uses the unity3d type
	# shellcheck disable=SC2039
	local application_type icon
	icon="$1"
	application_type="$(application_type "$(icon_application "$icon")")"
	if [ "$application_type" != 'unity3d' ]; then
		error_application_wrong_type 'icon_unity3d_path' "$application_type"
		return 1
	fi

	# Return early if UNITY3D_NAME is not set
	if [ -z "$(unity3d_name)" ]; then
		return 0
	fi

	# Compute the icon path from UNITY3D_NAME
	printf '%s_Data/Resources/UnityPlayer.png' "$(unity3d_name)"
}

