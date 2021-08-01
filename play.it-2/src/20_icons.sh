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

