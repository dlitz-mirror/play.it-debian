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

# get archive-specific value for a given variable name, or use default value
# USAGE: use_archive_specific_value $variable_name
# RETURN: nothing
# SIDE EFFECT: update the value of the variables using the given name
use_archive_specific_value() {
	###
	# TODO
	# We should check that a valid shell variable name has been passed
	###
	# shellcheck disable=SC2039
	local variable_name variable_value
	variable_name="$1"

	# Try to get an archive-specific value for the given variable
	variable_value=$(get_archive_specific_value "$variable_name")

	# If no archive-specific value exists, fall back on the default value
	if [ -z "$variable_value" ]; then
		variable_value=$(get_value "$variable_name")
	fi

	# Update the variable value
	export "$variable_name"="$variable_value"
	return 0
}

# return an archive-specific value for a given variable name, if one exists
# USAGE: get_archive_specific_value $variable_name
# RETURN: an archive-specific value, or nothing
get_archive_specific_value() {
	# If $ARCHIVE is not set, return early
	if [ -z "$ARCHIVE" ]; then
		return 0
	fi

	# Try to find a variable using the base name + the current archive identifier suffix
	# shellcheck disable=SC2039
	local variable_base_name variable_name_with_suffix archive_suffix variable_value
	variable_base_name="$1"

	# Try first with "ARCHIVE_BASE_" as the base archive identifier
	# This step should be skipped with game scripts targeting a library version older than 2.13
	if \
		# shellcheck disable=SC2154
		version_is_at_least '2.13' "$target_version" && \
		[ "${ARCHIVE#ARCHIVE_BASE_}" != "$ARCHIVE" ]
	then
		archive_suffix="${ARCHIVE#ARCHIVE_BASE_}"
		variable_name_with_suffix="${variable_base_name}_${archive_suffix}"
		while [ "$variable_name_with_suffix" != "$variable_base_name" ]; do
			variable_value=$(get_value "$variable_name_with_suffix")
			if [ -n "$variable_value" ]; then
				printf '%s' "$variable_value"
				return 0
			fi
			variable_name_with_suffix="${variable_name_with_suffix%_*}"
		done
	fi

	# If no value has been found using "ARCHIVE_BASE_" as the base archive identifier, try again using "ARCHIVE_"
	if [ "${ARCHIVE#ARCHIVE_}" != "$ARCHIVE" ]; then
		archive_suffix="${ARCHIVE#ARCHIVE_}"
		variable_name_with_suffix="${variable_base_name}_${archive_suffix}"
		while [ "$variable_name_with_suffix" != "$variable_base_name" ]; do
			variable_value=$(get_value "$variable_name_with_suffix")
			if [ -n "$variable_value" ]; then
				printf '%s' "$variable_value"
				return 0
			fi
			variable_name_with_suffix="${variable_name_with_suffix%_*}"
		done
	fi

	# No archive-specific value has been found
	# This should not trigger an error
	return 0
}

# get package-specific value for a given variable name, or use default value
# USAGE: use_package_specific_value $var_name
use_package_specific_value() {
	# get the current package
	local package
	package=$(package_get_current)

	local name_real
	name_real="$1"
	local name
	name="${name_real}_${package#PKG_}"
	local value
	while [ "$name" != "$name_real" ]; do
		value="$(get_value "$name")"
		if [ -n "$value" ]; then
			export ${name_real?}="$value"
			return 0
		fi
		name="${name%_*}"
	done
}

# get the value of a variable and print it
# USAGE: get_value $variable_name
get_value() {
	local name
	local value
	name="$1"
	value="$(eval printf -- '%b' \"\$$name\")"
	printf '%s' "$value"
}

# get the context-specific value of a variable and print it
# the context can be either the current archive or the current package
# if no context-specific value has been found, the default value is printed
# USAGE: get_context_specific_value archive|package $variable_name
# RETURN: the context-specific value for the given variable, or its default value
get_context_specific_value() {
	# Get the context suffix based on the context type
	# shellcheck disable=SC2039
	local context context_suffix
	context="$1"
	case "$context" in
		('archive'|'package')
			context_suffix=$(get_context_suffix "$context")
		;;
		(*)
			error_context_invalid "$context"
		;;
	esac

	# Try to find a context-specific value
	# shellcheck disable=SC2039
	local variable_name variable_name_with_suffix
	variable_name="$2"
	variable_name_with_suffix="${variable_name}_${context_suffix}"
	while [ "$variable_name_with_suffix" != "$variable_name" ]; do
		context_specific_value=$(get_value "$variable_name_with_suffix")
		# Exit the loop if a value has been found
		[ -n "$context_specific_value" ] && break
		# Drop one suffix level for the next loop iteration
		variable_name_with_suffix="${variable_name_with_suffix%_*}"
	done

	# Fall back on the default value
	if [ -z "$context_specific_value" ]; then
		context_specific_value=$(get_value "$variable_name")
	fi

	printf '%s' "$context_specific_value"
}

# get the context suffix and print it
# USAGE: get_context_suffix archive|package
# RETURN: the context suffix, not including the leading underscore (_)
get_context_suffix() {
	# shellcheck disable=SC2039
	local context context_suffix
	context="$1"
	case "$context" in
		('archive')
			get_context_suffix_archive
		;;
		('package')
			get_context_suffix_package
		;;
		(*)
			error_context_invalid "$context"
		;;
	esac
	printf '%s' "$context_suffix"
}

# get the current archive suffix and print it
# USAGE: get_context_suffix_archive
# RETURN: the current archive suffix, not including the leading underscore (_)
get_context_suffix_archive() {
	# Get the current archive, check that it is set
	# shellcheck disable=SC2039
	local current_archive
	current_archive="$ARCHIVE"
	if [ -z "$current_archive" ]; then
		error_archive_unset
	fi

	# Get the suffix from the full archive identifier
	# shellcheck disable=SC2039
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
	# shellcheck disable=SC2039
	local current_package
	current_package=$(package_get_current)

	# Get the suffix from the full package identifier
	# shellcheck disable=SC2039
	local package_suffix
	package_suffix=${current_package#PKG_}

	printf '%s' "$package_suffix"
}

