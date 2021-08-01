# print the path of the given icon
# USAGE: icon_path $icon
# RETURN: the icon path, it can include spaces
icon_path() {
	# Get the icon path from its identifier
	# shellcheck disable=SC2039
	local icon_path
	icon_path=$(get_context_specific_value 'archive' "$1")

	# Check that the path to the icon is not empty
	if [ -z "$icon_path" ]; then
		error_icon_path_empty "$icon"
	fi

	printf '%s' "$icon_path"
}

# print the wrestool options string for the given .exe icon
# USAGE: icon_wrestool_options $icon
# RETURN: the options string to pass to wrestool
icon_wrestool_options() {
	# shellcheck disable=SC2039
	local icon
	icon="$1"

	# Check that the given icon is a .exe file
	if ! icon_path "$icon" | grep --quiet '\.exe$'; then
		error_icon_unexpected_type "$icon" '*.exe'
		return 1
	fi

	# Fetch the custom options string
	# shellcheck disable=SC2039
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

