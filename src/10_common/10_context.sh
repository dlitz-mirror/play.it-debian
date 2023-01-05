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
