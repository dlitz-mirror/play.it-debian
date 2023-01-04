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
