# get the Unity3D name for the current game
# USAGE: unity3d_name
# RETURN: the Unity3D name, a string that can include spaces,
#         or an empty string if none is set
unity3d_name() {
	get_context_specific_value 'archive' 'UNITY3D_NAME'
}

