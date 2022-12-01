# Print the list of all icon identifiers.
# USAGE: icons_list_all
# RETURN: a list of icons identifiers, one per line,
#         or an empty string if no icon seems to be set
icons_list_all() {
	set | \
		grep --regexp='^APP_.*_ICON=' | \
		cut --delimiter='=' --fields=1

	# Include icons specific to the current archive context
	local archive_suffix
	archive_suffix="_$(get_context_suffix_archive)"
	while [ -n "$archive_suffix" ]; do
		set | \
			grep --regexp="^APP_.*_ICON${archive_suffix}=" | \
			cut --delimiter='=' --fields=1
		archive_suffix="${archive_suffix%_*}"
	done
}

# Print the list of icon identifiers for the given application.
# USAGE: application_icons_list $application
# RETURN: a space-separated list of icons identifiers,
#         or an empty string if no icon seems to be set
application_icons_list() {
	local application
	application="$1"

	# Use the value of APP_xxx_ICONS_LIST if it is set
	local icons_list
	icons_list=$(get_value "${application}_ICONS_LIST")
	if [ -n "$icons_list" ]; then
		printf '%s' "$icons_list"
		return 0
	fi

	# Fall back on the default value of a single APP_xxx_ICON icon
	local default_icon
	default_icon="${application}_ICON"
	## If a value is explicitly set for APP_xxx_ICON,
	## we assume this is the only icon for the current application.
	if [ -n "$(get_value "$default_icon")" ]; then
		printf '%s' "$default_icon"
		return 0
	fi
	## If no value is set for APP_xxx_ICON,
	## the behaviour depends on the application type.
	local application_type
	application_type=$(application_type "$application")
	case "$application_type" in
		('unity3d')
			# It is expected that Unity3D games always come with a single icon.
			printf '%s' "$default_icon"
			return 0
		;;
		('wine')
			# If no value is explicitly set for the icon of a WINE application,
			# we will fall back to extracting one from the binary.
			printf '%s' "$default_icon"
			return 0
		;;
	esac

	# If no icon has been found, there is nothing to print
	return 0
}

# print the application identifier for a given icon
# USAGE: icon_application $icon
# RETURN: the application identifier
icon_application() {
	# We assume here that the icon identifier is built from the application identifier,
	# with a suffix appended.
	local application applications_list icon
	icon="$1"
	applications_list=$(applications_list)

	# The applications list should not be empty if this function has been called
	if [ -z "$applications_list" ]; then
		error_applications_list_empty
		return 1
	fi

	for application in $applications_list; do
		if printf '%s' "$icon" | grep --quiet "^${application}"; then
			printf '%s' "$application"
			return 0
		fi
	done

	# If we reached this point, no application has been found for the current icon.
	# This should not happen.
	return 1
}

# print the path of the given icon
# USAGE: icon_path $icon
# RETURN: the icon path, it can include spaces
icon_path() {
	# Get the icon path from its identifier
	local icon icon_path
	icon="$1"
	icon_path=$(get_context_specific_value 'archive' "$icon")

	# If no value is set, try to find one based on the application type
	if [ -z "$icon_path" ]; then
		local application application_type
		application=$(icon_application "$icon")
		application_type=$(application_type "$application")
		if [ -z "$application_type" ]; then
			error_no_application_type "$application"
			return 1
		fi
		case "$application_type" in
			('unity3d')
				icon_path=$(icon_unity3d_path "$icon")
			;;
			('wine')
				icon_path=$(icon_wine_path "$icon")
			;;
		esac
	fi

	# Check that the path to the icon is not empty
	if [ -z "$icon_path" ]; then
		error_icon_path_empty "$icon"
		return 1
	fi

	printf '%s' "$icon_path"
}

# print the wrestool options string for the given .exe icon
# USAGE: icon_wrestool_options $icon
# RETURN: the options string to pass to wrestool
icon_wrestool_options() {
	local icon
	icon="$1"

	# Check that the given icon is a .exe file
	if ! icon_path "$icon" | grep --quiet '\.exe$'; then
		error_icon_unexpected_type "$icon" '*.exe'
		return 1
	fi

	# Fetch the custom options string
	wrestool_options=$(get_value "${icon}_WRESTOOL_OPTIONS")

	# If no custom value is set, falls back to defaults
	: "${wrestool_options:=--type=14}"

	###
	# TODO
	# This should be deprecated
	###
	# Check for an explicit wrestool id
	if [ -n "$(get_value "${icon}_ID")" ]; then
		wrestool_options="$wrestool_options --name=$(get_value "${icon}_ID")"
	fi

	printf '%s' "$wrestool_options"
}

