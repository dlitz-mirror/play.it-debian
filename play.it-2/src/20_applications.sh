# list application identifiers for the current game
# USAGE: applications_list
# RETURN: a space-separated list of application identifiers
applications_list() {
	# If APPLICATIONS_LIST is set, return it instead of trying to guess the list
	if [ -n "$APPLICATIONS_LIST" ]; then
		printf '%s' "$APPLICATIONS_LIST"
		return 0
	fi

	# If no value is set, try to guess one

	## Unity3D game
	if [ -n "$(unity3d_name)" ]; then
		# Unity3D games are expected to provide a single application
		printf '%s' 'APP_MAIN'
		return 0
	fi

	## Fallback, parse the game script
	local game_script
	game_script="$0"
	# Try to generate a list from the following variables:
	# - APP_xxx_EXE
	# - APP_xxx_SCUMMID
	# - APP_xxx_RESIDUALID
	local sed_expression application_id
	sed_expression='s/^\(APP_[0-9A-Z]\+\)_\(EXE\|SCUMMID\|RESIDUALID\)\(_[0-9A-Z]\+\)\?=.*/\1/p'
	while read -r application_id; do
		printf '%s ' "$application_id"
	done <<- EOF
	$(sed --silent --expression="$sed_expression" "$game_script")
	EOF
}

# print the type of the given application
# USAGE: application_type $application
# RETURN: the application type keyword, from the supported values:
#         - dosbox
#         - java
#         - mono
#         - native
#         - native_no-prefix
#         - renpy
#         - residualvm
#         - scummvm
#         - wine
application_type() {
	# Get the application type from its identifier
	local application_type
	application_type=$(get_value "${1}_TYPE")

	# If not type has been explicitely set, try to guess one
	if [ -z "$application_type" ]; then
		if [ -n "$(unity3d_name)" ]; then
			application_type='unity3d'
		fi
	fi

	# Check that a supported type has been fetched
	case "$application_type" in
		( \
			'dosbox' | \
			'java' | \
			'mono' | \
			'native' | \
			'native_no-prefix' | \
			'renpy' | \
			'residualvm' | \
			'scummvm' | \
			'unity3d' | \
			'wine' \
		)
			printf '%s' "$application_type"
			return 0
		;;
		(*)
			error_unknown_application_type "$application_type"
			return 1
		;;
	esac
}

# print the id of the given application
# USAGE: application_id $application
# RETURN: the application id, limited to the characters set [-_0-9a-z]
#         the id can not start nor end with a character from the set [-_]
application_id() {
	# Get the application type from its identifier
	local application_id
	application_id=$(get_value "${1}_ID")

	# If no id is explicitely set, fall back on GAME_ID
	: "${application_id:=$GAME_ID}"

	# Check that the id fits the format restrictions
	if ! printf '%s' "$application_id" | \
		grep --quiet --regexp='^[0-9a-z][-_0-9a-z]\+[0-9a-z]$'
	then
		error_application_id_invalid "$application" "$application_id"
		return 1
	fi

	printf '%s' "$application_id"
}

# print the file name of the given application
# USAGE: application_exe $application
# RETURN: the application file name
application_exe() {
	# Use the package-specific value if it is available,
	# falls back on the default value
	local application application_exe
	application="$1"
	application_exe=$(get_context_specific_value 'package' "${application}_EXE")

	# If no value is set, try to find one based on the application type
	if [ -z "$application_exe" ]; then
		local application_type
		application_type=$(application_type "$application")
		case "$application_type" in
			('unity3d')
				application_exe=$(application_unity3d_exe "$application")
			;;
		esac
	fi

	# Check that the file name is not empty
	if [ -z "$application_exe" ]; then
		error_application_exe_empty "$application" "$application_type"
	fi

	printf '%s' "$application_exe"
}

# print the name of the given application, for display in menus
# USAGE: application_name $application
# RETURN: the pretty version of the application name
application_name() {
	# Get the application name from its identifier
	local application_name
	application_name=$(get_value "${1}_NAME")

	# If no name is explicitely set, fall back on GAME_NAME
	: "${application_name:=$GAME_NAME}"

	printf '%s' "$application_name"
}

# print the category of the given application, for sorting in menus with categories support
# USAGE: application_category $application
# RETURN: the application XDG menu category
application_category() {
	# Get the application category from its identifier
	local application_category
	application_category=$(get_value "${1}_CAT")

	# If no category is explicitely set, fall back on "Game"
	: "${application_category:=Game}"

	# TODO - We could check that the category is part of the 1.0 XDG spec:
	# https://specifications.freedesktop.org/menu-spec/menu-spec-1.0.html#category-registry

	printf '%s' "$application_category"
}

# print the pre-run actions for the given application
# USAGE: application_prerun $application
# RETURN: the pre-run actions, can span over multiple lines,
#         or an empty string if there are none
application_prerun() {
	get_value "${1}_PRERUN"
}

# print the post-run actions for the given application
# USAGE: application_postrun $application
# RETURN: the post-run actions, can span over multiple lines,
#         or an empty string if there are none
application_postrun() {
	get_value "${1}_POSTRUN"
}

# print the options string for the given application
# USAGE: application_options $application
# RETURN: the options string on a single line,
#         or an empty string if no options are set
application_options() {
	# Get the application options string from its identifier
	local application application_options
	application="$1"
	application_options=$(get_value "${application}_OPTIONS")

	# Check that the options string does not span multiple lines
	if [ "$(printf '%s' "$application_options" | wc --lines)" -gt 1 ]; then
		error_variable_multiline "${application}_OPTIONS"
		return 1
	fi

	printf '%s' "$application_options"
}

# print the application libraries path, relative to the game root
# USAGE: application_libs $application
# RETURN: the application libraries path relative to the game root,
#         or an empty string if none is set
application_libs() {
	# Use the package-specific value if it is available,
	# falls back on the default value
	get_context_specific_value 'package' "${1}_LIBS"
}

# print the list of icon identifiers for the given application
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
	local default_icon application_type
	default_icon="${application}_ICON"
	application_type=$(application_type "$application")
	case "$application_type" in
		('unity3d')
			# It is expected that Unity3D games always come with a single icon
			printf '%s' "$default_icon"
			return 0
		;;
		(*)
			# If a value is explicitely set for APP_xxx_ICON,
			# we assume this is the only icon for the current application
			if [ -n "$(get_value "$default_icon")" ]; then
				printf '%s' "$default_icon"
				return 0
			fi
		;;
	esac

	# If no icon has been found, there is nothing to print
	return 0
}

