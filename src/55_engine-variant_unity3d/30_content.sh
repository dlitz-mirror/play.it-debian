# Print the Unity3D name for the current game
# This function should not fail if no Unity3D name is set for the current game,
# so it can be used to automatically detect games using the "unity3d" type variant.
# USAGE: unity3d_name
# RETURN: the Unity3D name, a string that can include spaces,
#         or an empty string if none is set
unity3d_name() {
	context_value 'UNITY3D_NAME'
}
