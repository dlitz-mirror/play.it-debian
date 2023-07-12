# WINE - Print the paths relative to the WINE prefix that should be diverted to persistent storage
# USAGE: wine_persistent_directories
# RETURN: A list of path to directories,
#         separated by line breaks.
wine_persistent_directories() {
	context_value 'WINE_PERSISTENT_DIRECTORIES'
}

