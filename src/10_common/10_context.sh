# Print the identifier of the current archive.
# USAGE: context_archive
# RETURNS: the current archive identifier,
#          or an empty string if no archive is set
context_archive() {
	if variable_is_empty 'ARCHIVE'; then
		# If $ARCHIVE is not explicitly set, return no value.
		# The calling function should check that what it got is not empty.
		return 0
	fi

	printf '%s' "$ARCHIVE"
}

# Print the identifier of the current package.
# USAGE: context_package
# RETURN: the current package identifier
context_package() {
	local package
	if variable_is_empty 'PKG'; then
		# If $PKG is not explicitly set,
		# return the first package from the list of packages to build.
		package=$(packages_get_list | cut --delimiter=' ' --fields=1)
	else
		package="$PKG"
	fi

	printf '%s' "$package"
}

# Print the suffix of the identifier of the current archive.
# USAGE: context_archive_suffix
# RETURN: the current archive identifier suffix including the leading underscore,
#         or an empty string if no archive is set
context_archive_suffix() {
	if ! version_is_at_least '2.21' "$target_version"; then
		context_archive_suffix_legacy
		return 0
	fi

	local archive
	archive=$(context_archive)

	printf '%s' "${archive#ARCHIVE_BASE}"
}

# Print the suffix of the identifier of the current package.
# USAGE: context_package_suffix
# RETURN: the current package identifier suffix including the leading underscore
context_package_suffix() {
	local package
	package=$(context_package)

	printf '%s' "${package#PKG}"
}

# Print the name of the variable containing the context-specific value of the given variable
# Context priority order is the following one:
# - archive-specific
# - package-specific
# - default
# - empty
# USAGE: context_name $variable_name
# RETURN: the name of the variable containing the context-specific value,
#         or an empty string
context_name() {
	local variable_name
	variable_name="$1"

	local context_archive_suffix context_package_suffix
	context_archive_suffix=$(context_archive_suffix)
	context_package_suffix=$(context_package_suffix)

	# Try to find an archive-specific value for the given variable.
	local context_name_archive
	if [ -n "$context_archive_suffix" ]; then
		context_name_archive=$(context_name_archive "$variable_name")
		if [ -n "$context_name_archive" ]; then
			printf '%s' "$context_name_archive"
			return 0
		fi
	fi

	# Try to find a package-specific value for the given variable.
	local context_name_package
	if [ -n "$context_package_suffix" ] ; then
		context_name_package=$(context_name_package "$variable_name")
		if [ -n "$context_name_package" ]; then
			printf '%s' "$context_name_package"
			return 0
		fi
	fi

	# Check if the base variable value is set.
	if ! variable_is_empty "$variable_name"; then
		printf '%s' "$variable_name"
		return 0
	fi

	# If no value has been found for the given variable, an empty string is returned.
}

# Print the name of the variable containing the archive-specific value of the given variable
# USAGE: context_name_archive $variable_name
# RETURN: the name of the variable containing the archive-specific value,
#         or an empty string
context_name_archive() {
	local variable_name
	variable_name="$1"

	local context_archive_suffix
	context_archive_suffix=$(context_archive_suffix)
	# Return early if no archive context is set
	if [ -z "$context_archive_suffix" ]; then
		return 0
	fi

	local context_archive_name
	while [ -n "$context_archive_suffix" ]; do
		context_archive_name="${variable_name}${context_archive_suffix}"
		if ! variable_is_empty "$context_archive_name"; then
			printf '%s' "$context_archive_name"
			return 0
		fi
		context_archive_suffix="${context_archive_suffix%_*}"
	done

	# If no value has been found for the given variable, an empty string is returned.
}

# Print the name of the variable containing the package-specific value of the given variable
# USAGE: context_name_package $variable_name
# RETURN: the name of the variable containing the package-specific value,
#         or an empty string
context_name_package() {
	local variable_name
	variable_name="$1"

	local context_package_suffix
	context_package_suffix=$(context_package_suffix)
	# Return early if no package context is set
	if [ -z "$context_package_suffix" ]; then
		return 0
	fi

	local context_package_name
	while [ -n "$context_package_suffix" ]; do
		context_package_name="${variable_name}${context_package_suffix}"
		if ! variable_is_empty "$context_package_name"; then
			printf '%s' "$context_package_name"
			return 0
		fi
		context_package_suffix="${context_package_suffix%_*}"
	done

	# If no value has been found for the given variable, an empty string is returned.
}

# Print the context-sensitive value for the given variable
# Context priority order is the following one:
# - archive-specific
# - package-specific
# - default
# - empty
# USAGE: context_value $variable_name
# RETURN: the context-sensitive value of the given variable,
#         or an empty string
context_value() {
	local variable_name
	variable_name="$1"

	local context_name
	context_name=$(context_name "$variable_name")
	# Return early if this variable has no set value.
	if [ -z "$context_name" ]; then
		return 0
	fi

	get_value "$context_name"
}
