# Compute the icon path from the UNITY3D_NAME value
# USAGE: icon_unity3d_path
# RETURN: the icon path, it can include spaces,
#         or an empty string
icon_unity3d_path() {
	local unity3d_name
	unity3d_name=$(unity3d_name)

	# FIXME - A critical error should be thrown if UNITY3D_NAME is not set.
	if [ -z "$unity3d_name" ]; then
		return 0
	fi

	printf '%s_Data/Resources/UnityPlayer.png' "$unity3d_name"
}
