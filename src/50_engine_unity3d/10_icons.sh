# compute the icon path from the UNITY3D_NAME value
# USAGE: icon_unity3d_path $icon
# RETURN: the icon path, it can include spaces,
#         or an empty string
icon_unity3d_path() {
	# Check that the application uses the unity3d type
	local icon application application_type
	icon="$1"
	application=$(icon_application "$icon")
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
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

