# Print the list of commands required by a given package
# USAGE: dependencies_list_commands $package
# RETURNS: a list of commands,
#          one per line
dependencies_list_commands() {
	local package
	package="$1"

	local dependencies_commands
	dependencies_commands=$(context_value "${package}_DEPENDENCIES_COMMANDS")
	# Return early if the current package does not require any command
	if [ -z "$dependencies_commands" ]; then
		return 0
	fi

	# Always return a list with no duplicate entry,
	# excluding empty lines.
	# Ignore grep error return if there is nothing to print.
	printf '%s' "$dependencies_commands" | \
		sort --unique | \
		grep --invert-match --regexp='^$' || true
}

# Add a command to the list of the given package.
# This function is used to update the commands dependencies list.
# USAGE: dependencies_add_command $package $dependency
dependencies_add_command() {
	local package dependency
	package="$1"
	dependency="$2"

	local current_dependencies
	current_dependencies=$(dependencies_list_commands "$package")

	local dependencies_variable_name
	dependencies_variable_name=$(context_name "${package}_DEPENDENCIES_COMMANDS")
	if [ -z "$dependencies_variable_name" ]; then
		dependencies_variable_name="${package}_DEPENDENCIES_COMMANDS"
	fi
	export $dependencies_variable_name="$current_dependencies
	$dependency"
}

# Print the path to a temporary files used for unknown commands listing
# USAGE: dependencies_unknown_commands_file
dependencies_unknown_commands_file() {
	printf '%s/unknown_commands_list' "$PLAYIT_WORKDIR"
}

# Print a list of unknown commands
# USAGE: dependencies_unknown_commands_list
dependencies_unknown_commands_list() {
	local unknown_commands_list
	unknown_commands_list=$(dependencies_unknown_commands_file)

	# Return early if there is no unknown command
	if [ ! -e "$unknown_commands_list" ]; then
		return 0
	fi

	# Display the list of unknown commands,
	# skipping duplicates and empty entries.
	sort --unique "$unknown_commands_list" | \
		grep --invert-match --regexp='^$'
}

# Clear the list of unknown commands
# USAGE: dependencies_unknown_commands_clear
dependencies_unknown_commands_clear() {
	local unknown_commands_list
	unknown_commands_list=$(dependencies_unknown_commands_file)

	rm --force "$unknown_commands_list"
}

# Add a command to the list of unknown ones
# USAGE: dependencies_unknown_command_add $unknown_command
dependencies_unknown_command_add() {
	local unknown_command
	unknown_command="$1"

	local unknown_commands_list
	unknown_commands_list=$(dependencies_unknown_commands_file)

	# Do nothing if this command is already included in the list
	if \
		[ -e "$unknown_commands_list" ] \
		&& grep --quiet --fixed-strings --word-regexp "$unknown_command" "$unknown_commands_list"
	then
		return 0
	fi

	printf '%s\n' "$unknown_command" >> "$unknown_commands_list"
}

