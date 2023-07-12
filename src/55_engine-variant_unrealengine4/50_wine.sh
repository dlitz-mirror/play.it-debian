# Unreal Engine 4 - Print the name of the renderer to use for Direct3D
# USAGE: unrealengine4_wine_renderer_name_default
unrealengine4_wine_renderer_name_default() {
	printf '%s' 'dxvk'
}

# Unreal Engine 4 - Print the paths relative to the WINE prefix that should be diverted to persistent storage
# USAGE: unrealengine4_wine_persistent_directories_default
# RETURN: A list of path to directories,
#         separated by line breaks.
unrealengine4_wine_persistent_directories_default() {
	local unrealengine4_name
	unrealengine4_name=$(unrealengine4_name)

	printf 'users/${USER}/AppData/Local/%s/Saved' "$unrealengine4_name"
}

