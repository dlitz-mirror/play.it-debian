# Print the Unity3D name for the current game
# This function should not fail if no Unity3D name is set for the current game,
# so it can be used to automatically detect games using the "unity3d" type variant.
# USAGE: unity3d_name
# RETURN: the Unity3D name, a string that can include spaces,
#         or an empty string if none is set
unity3d_name() {
	context_value 'UNITY3D_NAME'
}

# Print the list of Unity3D plugins to include for the current game
# USAGE: unity3d_plugins
# RETURN: the list of plugins to include, one per line
unity3d_plugins() {
	context_value 'UNITY3D_PLUGINS'
}

# Include the shipped Unity3D plugins into the current package
# USAGE: content_inclusion_unity3d_plugins $package
content_inclusion_unity3d_plugins() {
	local package
	package="$1"

	# Set the plugins source path
	local unity3d_name content_path plugins_directory plugins_path
	unity3d_name=$(unity3d_name)
	content_path=$(content_path_default)
	plugins_directory="${content_path}/${unity3d_name}_Data/Plugins"
	plugins_path="${PLAYIT_WORKDIR}/gamedata/${plugins_directory}"

	local CONTENT_UNITY3D_PLUGINS_FILES target_directory
	## Silence ShellCheck false-positive
	## CONTENT_UNITY3D_PLUGINS_FILES appears unused. Verify use (or export if used externally).
	# shellcheck disable=SC2034
	CONTENT_UNITY3D_PLUGINS_FILES=$(unity3d_plugins)
	target_directory=$(path_libraries)

	# Proceed with the actual files inclusion.
	local package_architecture architecture_string
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			architecture_string='x86'
		;;
		('64')
			architecture_string='x86_64'
		;;
		('all')
			# Return early if the current package should not include binaries.
			return 0
		;;
	esac
	if [ -d "${plugins_path}/${architecture_string}" ]; then
		local CONTENT_UNITY3D_PLUGINS_PATH
		## Silence ShellCheck false-positive
		## CONTENT_UNITY3D_PLUGINS_PATH appears unused. Verify use (or export if used externally).
		# shellcheck disable=SC2034
		CONTENT_UNITY3D_PLUGINS_PATH="${plugins_directory}/${architecture_string}"
		content_inclusion 'UNITY3D_PLUGINS' "$package" "$target_directory"

		# Delete the remaining plugins for the current architecture,
		# to prevent them from being included later.
		rm --force "${plugins_path}/${architecture_string}"/*
		rmdir --ignore-fail-on-non-empty --parents "${plugins_path}/${architecture_string}"
	fi

	# Some games include plugins in the "Plugins" directory,
	# without using an architecture sub-directory.
	if [ -d "$plugins_path" ]; then
		local CONTENT_UNITY3D_PLUGINS_PATH
		## Silence ShellCheck false-positive
		## CONTENT_UNITY3D_PLUGINS_FILES appears unused. Verify use (or export if used externally).
		# shellcheck disable=SC2034
		CONTENT_UNITY3D_PLUGINS_PATH="$plugins_directory"
		content_inclusion 'UNITY3D_PLUGINS' "$package" "$target_directory"
		rm --force "$plugins_path"/*.*
		rmdir --ignore-fail-on-non-empty --parents "$plugins_path"
	fi
}
