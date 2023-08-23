# Load options values from the configuration file.
# USAGE: load_configuration_file $config_file_path
load_configuration_file() {
	local config_file_path
	config_file_path="$1"

	# Default configuration file may not exist, ignoring this then.
	if [ ! -f "$config_file_path" ]; then
		return 0
	fi

	# Parse the configuration file.
	local arguments
	arguments=''
	while read -r line; do
		case $line in
			('#'*)
				# Ignore commented lines.
			;;
			(*)
				arguments="$arguments $line"
			;;
		esac
	done <<- EOF
		$(cat "$config_file_path")
	EOF

	parse_arguments_default $arguments
}

# Print the configuration file path.
# USAGE: find_configuration_file $arguments[…]
find_configuration_file() {
	local arguments_string
	arguments_string=$(getopt_arguments_cleanup "$@")
	eval set -- "$arguments_string"

	local config_file_path
	config_file_path=''

	# Override the default path if another one has been specified.
	while [ $# -gt 0 ]; do
		case "$1" in
			('--config-file')
				config_file_path="$2"
				break
			;;
		esac
		shift 1
	done

	if \
		[ -n "$config_file_path" ] \
		&& [ ! -f "$config_file_path" ]
	then
		error_config_file_not_found "$config_file_path"
		return 1
	fi

	# Fall back on the default path if no custom one is set.
	if [ -z "$config_file_path" ]; then
		config_file_path=$(configuration_file_default_path)
	fi

	printf '%s' "$config_file_path"
}

# Print the default path to the configuration file
# USAGE: configuration_file_default_path
# RETURN: a string representing a path to a file,
#         no check of the file actual existence is done
configuration_file_default_path() {
	local configuration_path
	if variable_is_empty 'XDG_CONFIG_HOME'; then
		configuration_path="${HOME}/.config"
	else
		configuration_path="$XDG_CONFIG_HOME"
	fi
	printf '%s/play.it/config' "$configuration_path"
}

