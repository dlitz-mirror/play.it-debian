# expand the given variable name and print its value
# USAGE: get_value $variable_name
# RETURN: the variable value
get_value() {
	local variable_name
	variable_name="$1"

	if ! variable_is_set "$variable_name"; then
		error_variable_not_set "$variable_name"
		return 1
	fi

	eval printf -- '%b' \"\$"${variable_name}"\"
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
			if variable_is_empty 'ARCHIVE'; then
				printf '%s' "$variable_name"
				return 0
			fi
			context_suffix=$(context_archive_suffix | sed 's/^_//')
		;;
		('package')
			# Return early if no package is explicitely set
			if variable_is_empty 'PKG'; then
				printf '%s' "$variable_name"
				return 0
			fi
			context_suffix=$(context_package_suffix | sed 's/^_//')
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
		if ! variable_is_empty "$variable_name_with_suffix"; then
			break
		fi
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

	# Only return a value if one is actually set.
	if ! variable_is_empty "$variable_name_with_context"; then
		get_value "$variable_name_with_context"
	fi
}
# Legacy alias for context_specific_value
# This should move into a compatibility source file at the next feature release.
get_context_specific_value() {
	context_specific_value "$1" "$2"
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

# Check if the given varible is unset or set to an empty value.
# USAGE: variable_is_empty $variable_name
# RETURN: 0 if the variable is unset or empty, 1 if it is set to a non empty value
variable_is_empty() {
	local variable_name
	variable_name="$1"
	if ! variable_is_set "$variable_name"; then
		return 0
	fi

	local variable_value
	variable_value=$(get_value "$variable_name")
	test -z "$variable_value"
}
