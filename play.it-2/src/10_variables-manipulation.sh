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

