# Unreal Engine 4 - Print the Unreal Engine 4 name for the current game
# This function should not fail if no Unreal Engine 4 name is set for the current game,
# so it can be used to automatically detect games using the "unrealengine4" type variant.
# USAGE: unrealengine4_name
# RETURN: the Unreal Engine 4 name, a string that can include spaces,
#         or an empty string if none is set
unrealengine4_name() {
	context_value 'UNREALENGINE4_NAME'
}

# Unreal Engine 4 - Print the list of files to include from the archive for a given identifier
# USAGE: unrealengine4_content_files_default $content_id
# RETURN: a list of paths relative to the path for the given identifier,
#         line breaks are used as separator between each item,
#         this list can include globbing patterns,
#         this list can be empty
unrealengine4_content_files_default() {
	local content_id
	content_id="$1"

	local unrealengine4_name
	unrealengine4_name=$(unrealengine4_name)

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
					Engine
					${unrealengine4_name}/Binaries
					${unrealengine4_name}/Plugins"
				;;
				('wine')
					content_files="
					engine
					${unrealengine4_name}/binaries
					${unrealengine4_name}/plugins
					${unrealengine4_name}.exe"
				;;
			esac
		;;
		('GAME_DATA')
			case "$application_type" in
				('native')
					content_files="
					${unrealengine4_name}/Content"
				;;
				('wine')
					content_files="
					${unrealengine4_name}/content"
				;;
			esac
		;;
	esac

	printf '%s' "${content_files:-}"
}

