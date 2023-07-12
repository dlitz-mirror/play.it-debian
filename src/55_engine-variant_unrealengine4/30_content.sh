# Unreal Engine 4 - Print the Unreal Engine 4 name for the current game
# This function should not fail if no Unreal Engine 4 name is set for the current game,
# so it can be used to automatically detect games using the "unrealengine4" type variant.
# USAGE: unrealengine4_name
# RETURN: the Unreal Engine 4 name, a string that can include spaces,
#         or an empty string if none is set
unrealengine4_name() {
	context_value 'UNREALENGINE4_NAME'
}

