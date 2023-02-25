# expand the given variable name and print its value
# USAGE: get_value $variable_name
# RETURN: the variable value
get_value() {
	local variable_name
	variable_name="$1"

	eval printf -- '%b' \"\$\{"${variable_name}":-\}\"
}

# Check if the given varible is unset or set to an empty value.
# USAGE: variable_is_empty $variable_name
# RETURN: 0 if the variable is unset or empty, 1 if it is set to a non empty value
variable_is_empty() {
	local variable_name
	variable_name="$1"

	local variable_value
	variable_value=$(get_value "$variable_name")
	test -z "$variable_value"
}
