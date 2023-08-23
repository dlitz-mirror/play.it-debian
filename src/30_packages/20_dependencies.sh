# Print the list of generic dependencies required by a given package
# USAGE: dependencies_list_generic $package
# RETURN: a list of generic dependcy keywords,
#         separated by line breaks
dependencies_list_generic() {
	local package
	package="$1"

	local dependencies_generic
	dependencies_generic=$(context_value "${package}_DEPS")

	# Always return a list with no duplicate entry,
	# excluding empty lines.
	# Ignore grep error return if there is nothing to print.
	printf '%s' "$dependencies_generic" | \
		sed 's/ /\n/g' | \
		sort --unique | \
		grep --invert-match --regexp='^$' || true
}

# Add a dependency to the list of the given package.
# This function is used to update the generic dependencies list.
# USAGE: dependencies_add_generic $package $dependency
dependencies_add_generic() {
	local package dependency
	package="$1"
	dependency="$2"

	local current_dependencies
	current_dependencies=$(dependencies_list_generic "$package")

	local dependencies_variable_name
	dependencies_variable_name=$(context_name "${package}_DEPS")
	if [ -z "$dependencies_variable_name" ]; then
		dependencies_variable_name="${package}_DEPS"
	fi
	export $dependencies_variable_name="$current_dependencies $dependency"
}
