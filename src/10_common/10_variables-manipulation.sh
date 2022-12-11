# test the validity of the argument given to parent function
# USAGE: testvar $var_name $pattern
testvar() {
	test "${1%%_*}" = "$2"
}

# expand the given variable name and print its value
# USAGE: get_value $variable_name
# RETURN: the variable value
get_value() {
	eval printf -- '%b' \"\$"$1"\"
}

# Print the context-specific name of a variable.
# The context can be either the current archive or the current package.
# If no context-specific name has been found, the default name is printed.
# USAGE: context_specific_name archive|package $variable_name
context_specific_name() {
	local variable_name
	variable_name="$2"

	# Get the context suffix based on the context type
	local context context_suffix
	context="$1"
	case "$context" in
		('archive')
			# Return early if no archive is explicitely set
			if [ -z "$ARCHIVE" ]; then
				printf '%s' "$variable_name"
				return 0
			fi
			context_suffix=$(get_context_suffix_archive)
		;;
		('package')
			# Return early if no package is explicitely set
			if [ -z "$PKG" ]; then
				printf '%s' "$variable_name"
				return 0
			fi
			context_suffix=$(get_context_suffix_package)
		;;
		(*)
			error_context_invalid "$context"
			return 1
		;;
	esac

	# Try to find a context-specific variable name with a value set.
	local variable_name_with_suffix
	variable_name_with_suffix="${variable_name}_${context_suffix}"
	while [ "$variable_name_with_suffix" != "$variable_name" ]; do
		# Exit the loop if the current variable name has a value set.
		[ -n "$(get_value "$variable_name_with_suffix")" ] && break
		# Drop one suffix level for the next loop iteration.
		variable_name_with_suffix="${variable_name_with_suffix%_*}"
	done

	# If the whole while loop went through without finding a context-specific value,
	# $variable_name_with_suffix is now equal to $variable_name.
	printf '%s' "$variable_name_with_suffix"
}

# Print the context-specific value of a variable.
# The context can be either the current archive or the current package.
# If no context-specific value has been found, the default value is printed.
# USAGE: context_specific_value archive|package $variable_name
context_specific_value() {
	local context variable_name
	context="$1"
	variable_name="$2"

	local variable_name_with_context
	variable_name_with_context=$(context_specific_name "$context" "$variable_name")

	get_value "$variable_name_with_context"
}
# Legacy alias for context_specific_value
# This should move into a compatibility source file at the next feature release.
get_context_specific_value() {
	context_specific_value "$1" "$2"
}

# get the current archive suffix and print it
# USAGE: get_context_suffix_archive
# RETURN: the current archive suffix, not including the leading underscore (_)
get_context_suffix_archive() {
	# Get the current archive, check that it is set
	local current_archive
	current_archive="$ARCHIVE"
	if [ -z "$current_archive" ]; then
		error_archive_unset
		return 1
	fi

	# Get the suffix from the full archive identifier
	local archive_suffix
	if \
		# shellcheck disable=SC2154
		version_is_at_least '2.13' "$target_version" && \
		[ "${ARCHIVE#ARCHIVE_BASE_}" != "$ARCHIVE" ]
	then
		archive_suffix=${ARCHIVE#ARCHIVE_BASE_}
	else
		archive_suffix=${ARCHIVE#ARCHIVE_}
	fi

	printf '%s' "$archive_suffix"
}

# get the current package suffix and print it
# USAGE: get_context_suffix_package
# RETURN: the current package suffix, not including the leading underscore (_)
get_context_suffix_package() {
	# Get the current package
	local current_package
	current_package=$(package_get_current)

	# Get the suffix from the full package identifier
	local package_suffix
	package_suffix=${current_package#PKG_}

	printf '%s' "$package_suffix"
}

# Check if the given variable is set.
# Warning: a variable can be set but empty.
# USAGE: variable_is_set $variable_name
# RETURN: 0 if the variable is set, 1 if it is unset
variable_is_set() {
	local variable_name
	variable_name="$1"
	set | grep --quiet --regexp="^${variable_name}="
}
