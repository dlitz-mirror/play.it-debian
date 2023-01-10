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
