# list application identifiers for the current game
# USAGE: applications_list
# RETURN: a space-separated list of application identifiers
applications_list() {
	# Return APPLICATIONS_LIST value, if it is explicitly set.
	# Context-specific values are supported.
	local applications_list
	applications_list=$(context_value 'APPLICATIONS_LIST')
	if [ -n "$applications_list" ]; then
		printf '%s' "$applications_list"
		return 0
	fi

	# If no value is set, try to guess one

	## Unity3D game
	local unity3d_name
	unity3d_name=$(unity3d_name)
	if [ -n "$unity3d_name" ]; then
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
		if [ -n "$application_id" ]; then
			# Do not add duplicates
			if \
				! printf '%s' "$applications_list" | \
				grep --quiet --fixed-strings --word-regexp "$application_id"
			then
				applications_list="$applications_list $application_id"
			fi
		fi
	done <<- EOF
	$(sed --silent --expression="$sed_expression" "$game_script")
	EOF

	if [ -n "$applications_list" ]; then
		printf '%s\n' "$applications_list" | sort --unique
		return 0
	fi

	# This function does not error out if the list is empty,
	# callers should handle this case.
}

# Print the type of prefix to use for the given application.
# If no type is explicitely set from the game script, it defaults to "symlinks".
# USAGE: application_prefix_type $application
# RETURN: the prefix type keyword, from the supported values:
#         - symlinks
#         - none
application_prefix_type() {
	# Prefix types:
	# - "symlinks", the default, generate our usual symbolic links farm
	# - "none", no prefix is generated, the game is run from the read-only system directory

	local application
	application="$1"

	# The default for most application types is "symlinks".
	local prefix_type
	prefix_type='symlinks'

	# ScummVM and ResidualVM applications default to "none".
	local application_type
	application_type=$(application_type "$application")
	if [ -z "$application_type" ]; then
		error_no_application_type "$application"
		return 1
	fi
	case "$application_type" in
		('scummvm'|'residualvm')
			prefix_type='none'
		;;
	esac

	# Override default with explicitely set prefix type for the current game.
	if ! variable_is_empty 'APPLICATIONS_PREFIX_TYPE'; then
		prefix_type="$APPLICATIONS_PREFIX_TYPE"
	fi

	# Override default with explicitely set prefix type for the given application.
	local prefix_type_override
	prefix_type_override=$(get_value "${application}_PREFIX_TYPE")
	if [ -n "$prefix_type_override" ]; then
		prefix_type="$prefix_type_override"
	fi

	# Check that a supported prefix type has been fetched
	case "$prefix_type" in
		('symlinks'|'none')
			## This is a supported type, no error to throw.
		;;
		(*)
			error_unknown_prefix_type "$prefix_type"
			return 1
		;;
	esac

	printf '%s' "$prefix_type"
}

# print the id of the given application
# USAGE: application_id $application
# RETURN: the application id, limited to the characters set [-_0-9a-z]
#         the id can not start nor end with a character from the set [-_]
application_id() {
	local application
	application="$1"

	# Get the application type from its identifier
	# Fall back on the game id if no value is set
	local application_id
	application_id=$(context_value "${application}_ID")
	if [ -z "$application_id" ]; then
		application_id=$(game_id)
	fi

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
# RETURN: the application file name,
#         or an empty string is none is set
application_exe() {
	local application application_exe
	application="$1"
	application_exe=$(context_value "${application}_EXE")

	# If no value is set, try to find one based on the application type
	if [ -z "$application_exe" ]; then
		local application_type_variant
		application_type_variant=$(application_type_variant "$application")
		case "$application_type_variant" in
			('unity3d')
				application_exe=$(application_unity3d_exe "$application")
			;;
		esac
	fi

	printf '%s' "$application_exe"
}

# print the file name of the application, with single quotes escaped,
# for inclusion in a single quote delimited variable declaration.
# USAGE: application_exe_escaped $application
# RETURN: the application file name with single quotes escaped
application_exe_escaped() {
	local application
	application="$1"

	local application_exe
	application_exe=$(application_exe "$application")
	## Check that application binary has been found
	if [ -z "$application_exe" ]; then
		error_application_exe_empty "$application"
		return 1
	fi
	# If the file name includes single quotes, replace each one with: '\''
	printf '%s' "$application_exe" | sed "s/'/'\\\''/g"
}

# Print the full path to the application binary.
# USAGE: application_exe_path $application_exe
# RETURN: the full path to the application binary,
#         or an empty string if it could not be found.
application_exe_path() {
	local application_exe
	application_exe="$1"

	# Look for the application binary in the temporary path for archive content.
	local content_path application_exe_path
	content_path=$(content_path_default)
	application_exe_path="${PLAYIT_WORKDIR}/gamedata/${content_path}/${application_exe}"
	if [ -f "$application_exe_path" ]; then
		printf '%s' "$application_exe_path"
		return 0
	fi

	# Look for the application binary in the current package.
	local package package_path path_game_data
	package=$(context_package)
	package_path=$(package_path "$package")
	path_game_data=$(path_game_data)
	application_exe_path="${package_path}${path_game_data}/${application_exe}"
	if [ -f "$application_exe_path" ]; then
		printf '%s' "$application_exe_path"
		return 0
	fi

	# Look for the application binary in all packages.
	local packages_list
	packages_list=$(packages_get_list)
	for package in $packages_list; do
		package_path=$(package_path "$package")
		application_exe_path="${package_path}${path_game_data}/${application_exe}"
		if [ -f "$application_exe_path" ]; then
			printf '%s' "$application_exe_path"
			return 0
		fi
	done
}

# print the name of the given application, for display in menus
# USAGE: application_name $application
# RETURN: the pretty version of the application name
application_name() {
	local application
	application="$1"

	# Get the application name from its identifier
	# Fall back on the game name if no value is set
	local application_name
	application_name=$(context_value "${application}_NAME")
	if [ -z "$application_name" ]; then
		application_name=$(game_name)
	fi

	printf '%s' "$application_name"
}

# print the category of the given application, for sorting in menus with categories support
# USAGE: application_category $application
# RETURN: the application XDG menu category
application_category() {
	local application
	application="$1"

	# Get the application category from its identifier
	local application_category
	application_category=$(get_value "${application}_CAT")
	## If no category is explicitely set, fall back on "Game"
	if [ -z "$application_category" ]; then
		application_category='Game'
	fi

	# TODO - We could check that the category is part of the 1.0 XDG spec:
	# https://specifications.freedesktop.org/menu-spec/menu-spec-1.0.html#category-registry

	printf '%s' "$application_category"
}

# Print the pre-run actions for the given application.
# USAGE: application_prerun $application
# RETURN: the pre-run actions, can span over multiple lines,
#         or an empty string if there are none
application_prerun() {
	local application
	application="$1"

	if variable_is_empty "${application}_PRERUN"; then
		return 0
	fi

	local application_type application_prerun
	application_type=$(application_type "$application")
	case "$application_type" in
		('dosbox')
			application_prerun=$(application_prerun_dosbox "$application")
		;;
		(*)
			application_prerun=$(get_value "${application}_PRERUN")
		;;
	esac

	# Ensure the pre-run actions string always end with a line break.
	printf '%s\n' "$application_prerun"
}

# Print the post-run actions for the given application.
# USAGE: application_postrun $application
# RETURN: the post-run actions, can span over multiple lines,
#         or an empty string if there are none
application_postrun() {
	local application
	application="$1"

	if variable_is_empty "${application}_POSTRUN"; then
		return 0
	fi

	local application_type application_postrun
	application_type=$(application_type "$application")
	case "$application_type" in
		('dosbox')
			application_postrun=$(application_postrun_dosbox "$application")
		;;
		(*)
			application_postrun=$(get_value "${application}_POSTRUN")
		;;
	esac

	# Ensure the post-run actions string always end with a line break.
	printf '%s\n' "$application_postrun"
}

# print the options string for the given application
# USAGE: application_options $application
# RETURN: the options string on a single line,
#         or an empty string if no options are set
application_options() {
	# Get the application options string from its identifier
	local application application_options
	application="$1"
	application_options=$(context_value "${application}_OPTIONS")

	# Check that the options string does not span multiple lines
	if [ "$(printf '%s' "$application_options" | wc --lines)" -gt 1 ]; then
		error_variable_multiline "${application}_OPTIONS"
		return 1
	fi

	printf '%s' "$application_options"
}

# Legacy - Print the application libraries path, relative to the game root.
# This function is deprecated, starting with ./play.it 2.19.
# New game scripts should no longer rely on the APP_xxx_LIBS variable.
# USAGE: application_libs $application
# RETURN: the application libraries path relative to the game root,
#         or an empty string if none is set
application_libs() {
	# Use the context-specific value if it is available,
	# falls back on the default value
	context_value "${1}_LIBS"
}
