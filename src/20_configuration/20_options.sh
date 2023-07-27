# Set default values for all options
# USAGE: options_init_default
options_init_default() {
	# Using a direct export call here instead of relying on option_update_default
	# massively improves performances when running a lot of ./play.it calls,
	# like what is done by the --list-supported-games option.
	export \
		PLAYIT_DEFAULT_OPTION_CHECKSUM='md5' \
		PLAYIT_DEFAULT_OPTION_COMPRESSION='none' \
		PLAYIT_DEFAULT_OPTION_OUTPUT_DIR="$PWD" \
		PLAYIT_DEFAULT_OPTION_PACKAGE='deb' \
		PLAYIT_DEFAULT_OPTION_PREFIX='/usr' \
		PLAYIT_DEFAULT_OPTION_TMPDIR="${TPMDIR:-/tmp}" \
		PLAYIT_DEFAULT_OPTION_FREE_SPACE_CHECK=1 \
		PLAYIT_DEFAULT_OPTION_ICONS=1 \
		PLAYIT_DEFAULT_OPTION_MTREE=1 \
		PLAYIT_DEFAULT_OPTION_DEBUG=0 \
		PLAYIT_DEFAULT_OPTION_HELP=0 \
		PLAYIT_DEFAULT_OPTION_LIST_AVAILABLE_SCRIPTS=0 \
		PLAYIT_DEFAULT_OPTION_LIST_PACKAGES=0 \
		PLAYIT_DEFAULT_OPTION_LIST_REQUIREMENTS=0 \
		PLAYIT_DEFAULT_OPTION_LIST_SUPPORTED_GAMES=0 \
		PLAYIT_DEFAULT_OPTION_OVERWRITE=0 \
		PLAYIT_DEFAULT_OPTION_SHOW_GAME_SCRIPT=0 \
		PLAYIT_DEFAULT_OPTION_VERSION=0
}

# Get the name of the variable used to store the value of the given option
# USAGE: option_variable $option_name
# RETURN: the variable name
option_variable() {
	local option_name
	option_name="$1"

	# The environment variable used to store an option is derived from its name:
	# - replace "-" with "_"
	# - convert to uppercase
	# - prepend "PLAYIT_OPTION_"
	# As an exemple, the value of the option "output-dir" would be stored in the following variable:
	# PLAYIT_OPTION_OUTPUT_DIR
	printf 'PLAYIT_OPTION_%s' "$(
		printf '%s' "$option_name" | \
			sed 's/-/_/g' | \
			tr '[:lower:]' '[:upper:]'
	)"
}

# Get the name of the variable used to store the default value of the given option
# USAGE: option_variable_default $option_name
# RETURN: the variable name
option_variable_default() {
	local option_name
	option_name="$1"

	# The environment variable used to store an option is derived from its name:
	# - replace "-" with "_"
	# - convert to uppercase
	# - prepend "PLAYIT_DEFAULT_OPTION_"
	# As an exemple, the default value of the option "output-dir" would be stored in the following variable:
	# PLAYIT_DEFAULT_OPTION_OUTPUT_DIR
	printf 'PLAYIT_DEFAULT_OPTION_%s' "$(
		printf '%s' "$option_name" | \
			sed 's/-/_/g' | \
			tr '[:lower:]' '[:upper:]'
	)"
}

# Update the value of the given option
# USAGE: option_update $option_name $option_value
option_update() {
	local option_name option_value
	option_name="$1"
	option_value="$2"

	local option_variable
	option_variable=$(option_variable "$option_name")
	export $option_variable="$option_value"

	option_validity_check "$option_name"

	if ! version_is_at_least '2.23' "$target_version"; then
		option_export_legacy "$option_name"
	fi
}

# Update the default value of the given option
# USAGE: option_update_default $option_name $option_value
option_update_default() {
	local option_name option_value
	option_name="$1"
	option_value="$2"

	local option_variable
	option_variable=$(option_variable_default "$option_name")
	export $option_variable="$option_value"

	case "$option_name" in
		('output-dir'|'tmpdir')
			# Directory existence check should be skipped when setting default options,
			# because we might be in a no-op situation (--help, --version, etc.)
			# but we do not know about it yet.
		;;
		(*)
			option_validity_check "$option_name"
		;;
	esac
}

# Get the value of the given option
# USAGE: option_value $option_name
# RETURN: the option value
option_value() {
	local option_name
	option_name="$1"

	local option_variable option_value
	option_variable=$(option_variable "$option_name")
	option_value=$(get_value "$option_variable")
	if [ -n "$option_value" ]; then
		printf '%s' "$option_value"
		return 0
	fi

	# If no value is explicitly set, return the default one
	option_variable=$(option_variable_default "$option_name")
	get_value "$option_variable"
}

# Check the validity of the given option
# USAGE: option_validity_check $option_name
# RETURN: nothing if the option value is valid,
#         throw an error otherwise
option_validity_check() {
	local option_name
	option_name="$1"

	# The "option_value" function can not be used here,
	# to avoid a loop between "option_value" and the current function.
	local option_variable option_value
	option_variable=$(option_variable "$option_name")
	option_value=$(get_value "$option_variable")
	if [ -z "$option_value" ]; then
		option_variable=$(option_variable_default "$option_name")
		option_value=$(get_value "$option_variable")
	fi
	case "$option_name" in
		('checksum')
			case "$option_value" in
				('md5'|'none')
					return 0
				;;
			esac
		;;
		('compression')
			case "$option_value" in
				('none'|'speed'|'size'|'auto')
					return 0
				;;
			esac
		;;
		('debug')
			case "$option_value" in
				([0-9])
					return 0
				;;
			esac
		;;
		('free-space-check')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('help')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('icons')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('list-available-scripts')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('list-packages')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('list-requirements')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('list-supported-games')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('mtree')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('output-dir')
			# Check that the value of "output-dir" is a path to a writable directory.

			## This check is not useful if a no-op option has been set.
			local noop_option noop_option_value
			for noop_option in \
				'help' \
				'list-available-scripts' \
				'list-packages' \
				'list-requirements' \
				'list-supported-games' \
				'show-game-script' \
				'version'
			do
				noop_option_value=$(option_value "$noop_option")
				if [ "${noop_option_value:-0}" -eq 1 ]; then
					return 0
				fi
			done

			local output_dir_path
			output_dir_path=$(printf '%s' "$option_value" | sed "s#^~/#${HOME}/#")
			if [ ! -d "$output_dir_path" ]; then
				error_not_a_directory "$output_dir_path"
				return 1
			fi
			if [ ! -w "$output_dir_path" ]; then
				error_not_writable "$output_dir_path"
				return 1
			fi
			return 0
		;;
		('overwrite')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('package')
			case "$option_value" in
				('arch'|'deb'|'gentoo'|'egentoo')
					return 0
				;;
			esac
		;;
		('prefix')
			# Check that the value of "prefix" is representing an absolute path.
			if printf '%s' "$option_value" | grep --quiet --regexp '^/'; then
				return 0
			fi
		;;
		('show-game-script')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		('tmpdir')
			# Check that the value of "tmpdir" is a path to a writable directory.

			## This check is not useful if a no-op option has been set.
			local noop_option noop_option_value
			for noop_option in \
				'help' \
				'list-available-scripts' \
				'list-packages' \
				'list-requirements' \
				'list-supported-games' \
				'show-game-script' \
				'version'
			do
				noop_option_value=$(option_value "$noop_option")
				if [ "${noop_option_value:-0}" -eq 1 ]; then
					return 0
				fi
			done

			local tmpdir_path
			tmpdir_path=$(printf '%s' "$option_value" | sed "s#^~/#${HOME}/#")
			if [ ! -d "$tmpdir_path" ]; then
				error_not_a_directory "$tmpdir_path"
				return 1
			fi
			if [ ! -w "$tmpdir_path" ]; then
				error_not_writable "$tmpdir_path"
				return 1
			fi
			return 0
		;;
		('version')
			case "$option_value" in
				(0|1)
					return 0
				;;
			esac
		;;
		(*)
			error_option_unknown "$option_name"
			return 1
		;;
	esac

	# Throw an error if we are not in one of the valid cases
	error_option_invalid "$option_name" "$option_value"
	return 1
}

# Check the compatibility of all set options
# USAGE: options_compatibility_check
# RETURN: nothing if all the current options are valid used together,
#         throw an error otherwise
options_compatibility_check() {
	# Check the compatibility of --compression auto with the target package format.
	local option_compression
	option_compression=$(option_value 'compression')
	if [ "$option_compression" = 'auto' ]; then
		local option_package
		option_package=$(option_value 'package')
		case "$option_package" in
			('arch')
				# --compression auto has not been implemented for Arch Linux packages yet.
				error_incompatible_options 'package' 'compression'
				return 1
			;;
		esac
	fi
}

