# WINE - Print the paths relative to the WINE prefix that should be diverted to persistent storage
# USAGE: wine_persistent_directories
# RETURN: A list of path to directories,
#         separated by line breaks.
wine_persistent_directories() {
	context_value 'WINE_PERSISTENT_DIRECTORIES'
}

# WINE - Print the list of winetricks verb that should be applied during the WINE prefix initialization
# USAGE: wine_winetricks_verbs
# RETURN: A list of winetricks verbs,
#         the list can be empty.
wine_winetricks_verbs() {
	context_value 'APP_WINETRICKS'
}

