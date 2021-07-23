# list application identifiers for the current game
# USAGE: applications_list
# RETURN: a space-separated list of application identifiers
applications_list() {
	# If APPLICATIONS_LIST is set, return it instead of trying to guess the list
	if [ -n "$APPLICATIONS_LIST" ]; then
		printf '%s' "$APPLICATIONS_LIST"
		return 0
	fi

	# If APPLICATIONS_LIST is not set, try to guess a list by parsing the game script
	# shellcheck disable=SC2039
	local game_script
	game_script="$0"

	# Try to generate a list from the following variables:
	# - APP_xxx_EXE
	# - APP_xxx_SCUMMID
	# - APP_xxx_RESIDUALID
	# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
	local application_type
	application_type=$(get_value "${1}_TYPE")

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
			'wine' \
		)
			printf '%s' "$application_type"
			return 0
		;;
		(*)
			error_unknown_application_type "$application_type"
		;;
	esac
}

