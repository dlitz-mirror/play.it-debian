# Compute the icon path from the APP_xxx_EXE value
# USAGE: icon_wine_path $icon
# RETURN: the icon path, it can include spaces,
#         or an empty string
icon_wine_path() {
	# Get the application identifier from the icon identifier.
	local icon application
	icon="$1"
	application=$(icon_application "$icon")

	# Check that the application uses the "wine" type.
	local application_type
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
	if [ "$application_type" != 'wine' ]; then
		error_application_wrong_type 'icon_wine_path' "$application_type"
		return 1
	fi

	# Print the path to the game binary.
	application_exe "$application"
}
