# WINE - Print the paths relative to the WINE prefix that should be diverted to persistent storage
# USAGE: wine_persistent_directories
# RETURN: A list of path to directories,
#         separated by line breaks.
wine_persistent_directories() {
	local persistent_directories
	persistent_directories=$(context_value 'WINE_PERSISTENT_DIRECTORIES')

	# Fall back on default values based on the game engine
	if [ -z "$persistent_directories" ]; then
		## Unreal Engine 4
		local unrealengine4_name
		unrealengine4_name=$(unrealengine4_name)
		if [ -n "$unrealengine4_name" ]; then
			persistent_directories=$(unrealengine4_wine_persistent_directories_default)
		fi
	fi

	printf '%s' "$persistent_directories"
}

# WINE - Print the list of winetricks verb that should be applied during the WINE prefix initialization
# USAGE: wine_winetricks_verbs
# RETURN: A list of winetricks verbs,
#         the list can be empty.
wine_winetricks_verbs() {
	local winetricks_verbs
	winetricks_verbs=$(context_value 'WINE_WINETRICKS_VERBS')

	# Fall back on the legacy variable, for game scripts targeting ./play.it ≤ 2.25
	if \
		[ -z "$winetricks_verbs" ] && \
		! version_is_at_least '2.26' "$target_version"
	then
		winetricks_verbs=$(context_value 'APP_WINETRICKS')
		if \
			[ -n "$winetricks_verbs" ] && \
			version_is_at_least '2.25' "$target_version"
		then
			warning_deprecated_variable 'APP_WINETRICKS' 'WINE_WINETRICKS_VERBS'
		fi
	fi

	# Fall back on default values based on the game engine
	if [ -z "$winetricks_verbs" ]; then
		## Unreal Engine 4
		local unrealengine4_name
		unrealengine4_name=$(unrealengine4_name)
		if [ -n "$unrealengine4_name" ]; then
			winetricks_verbs=$(unrealengine4_wine_winetricks_verbs_default)
		fi
	fi

	printf '%s' "$winetricks_verbs"
}

