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

# Unity3D - Print the list of files to include from the archive for a given identifier
# USAGE: unity3d_content_files_default $content_id
# RETURN: a list of paths relative to the path for the given identifier,
#         line breaks are used as separator between each item,
#         this list can include globbing patterns,
#         this list can be empty
unity3d_content_files_default() {
	local content_id
	content_id="$1"

	local unity3d_name
	unity3d_name=$(unity3d_name)

	local applications_list application application_type
	applications_list=$(applications_list)
	if [ -z "$applications_list" ]; then
		error_applications_list_empty
	fi
	## FIXME - Trim leading spaces from the application list, this should be done by the applications_list function.
	application=$(printf '%s' "$applications_list" | grep --only-matching '[^ ].*' | cut --delimiter=' ' --fields=1)
	application_type=$(application_type "$application")

	local content_files
	case "$content_id" in
		('GAME_BIN')
			case "$application_type" in
				('native')
					content_files="
					MonoBleedingEdge
					${unity3d_name}_Data/Mono
					${unity3d_name}_Data/MonoBleedingEdge
					${unity3d_name}.x86_64
					${unity3d_name}.x86
					${unity3d_name}
					*.so"
				;;
				('wine')
					content_files="
					Mono
					mono
					MonoBleedingEdge
					monobleedingedge
					${unity3d_name}_Data/Mono
					${unity3d_name}_data/mono
					${unity3d_name}_Data/MonoBleedingEdge
					${unity3d_name}_data/monobleedingedge
					${unity3d_name}_Data/Plugins
					${unity3d_name}_data/plugins
					${unity3d_name}.exe
					*.dll"
				;;
			esac
		;;
		('GAME_BIN32')
			case "$application_type" in
				('native')
					content_files="
					MonoBleedingEdge/x86
					${unity3d_name}_Data/Mono/x86
					${unity3d_name}_Data/MonoBleedingEdge/x86
					${unity3d_name}.x86
					${unity3d_name}"
				;;
			esac
		;;
		('GAME_BIN64')
			case "$application_type" in
				('native')
					content_files="
					MonoBleedingEdge/x86_64
					${unity3d_name}_Data/Mono/x86_64
					${unity3d_name}_Data/MonoBleedingEdge/x86_64
					${unity3d_name}.x86_64
					${unity3d_name}"
				;;
			esac
		;;
		('GAME_DATA')
			case "$application_type" in
				('native')
					content_files="
					${unity3d_name}_Data"
				;;
				('wine')
					content_files="
					${unity3d_name}_Data
					${unity3d_name}_data"
				;;
			esac
		;;
	esac

	printf '%s' "${content_files:-}"
}

