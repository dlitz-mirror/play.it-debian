# Set default values for all options
# USAGE: options_init_default
options_init_default() {
	option_update_default 'checksum' 'md5'
	option_update_default 'compression' 'none'
	option_update_default 'output-dir' "$PWD"
	option_update_default 'package' 'deb'
	option_update_default 'prefix' '/usr'
	option_update_default 'tmpdir' "${TMPDIR:-/tmp}"

	# Boolean options enabled by default
	option_update_default 'free-space-check' 1
	option_update_default 'icons' 1
	option_update_default 'mtree' 1

	# Boolean options disabled by default
	option_update_default 'debug' 0
	option_update_default 'help' 0
	option_update_default 'list-packages' 0
	option_update_default 'list-requirements' 0
	option_update_default 'overwrite' 0
	option_update_default 'show-game-script' 0
	option_update_default 'version' 0
}

# Test is a given option is set
# USAGE: option_is_set $option_name
# RETURN: 0 if the option is set,
#         1 if it is unset
option_is_set() {
	local option_name
	option_name="$1"

	local option_variable
	option_variable=$(option_variable "$option_name")

	! variable_is_empty "$option_variable"
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
}

# Get the value of the given option
# USAGE: option_value $option_name
# RETURN: the option value,
#         or an empty string if it is not set
option_value() {
	local option_name
	option_name="$1"

	option_validity_check "$option_name"

	local option_variable
	option_variable=$(option_variable "$option_name")

	get_value "$option_variable"
}

# Get the default value of the given option
# USAGE: option_value_default $option_name
# RETURN: the default option value,
#         or an empty string if none is set
option_value_default() {
	local option_name
	option_name="$1"

	local option_variable_default
	option_variable_default=$(option_variable_default "$option_name")

	get_value "$option_variable_default"
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
	if variable_is_empty "$option_variable"; then
		option_value=''
	else
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
				('none'|'speed'|'size')
					return 0
				;;
			esac
			if ! version_is_at_least '2.23' "$target_version"; then
				option_validity_check_compression_legacy "$option_value"
				# Ensure the warning is only displayed once
				if variable_is_empty 'PLAYIT_WARNING_LEGACY_COMPRESSION_SHOWN'; then
					warning_option_value_deprecated "$option_name" "$option_value"
					export PLAYIT_WARNING_LEGACY_COMPRESSION_SHOWN=1
				fi
				return 0
			fi
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
			local noop_option noop_option_variable noop_option_value
			for noop_option in \
				'help' \
				'list-packages' \
				'list-requirements' \
				'show-game-script' \
				'version'
			do
				noop_option_variable=$(option_variable "$noop_option")
				if ! variable_is_empty "$noop_option_variable"; then
					noop_option_value=$(option_value "$noop_option")
					if [ "$noop_option_value" -eq 1 ]; then
						return 0
					fi
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
			local noop_option noop_option_variable noop_option_value
			for noop_option in \
				'help' \
				'list-packages' \
				'list-requirements' \
				'show-game-script' \
				'version'
			do
				noop_option_variable=$(option_variable "$noop_option")
				if ! variable_is_empty "$noop_option_variable"; then
					noop_option_value=$(option_value "$noop_option")
					if [ "$noop_option_value" -eq 1 ]; then
						return 0
					fi
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
	# Check the compatibility of the "package" and "compression" values,
	# when using legacy compression values.
	if ! version_is_at_least '2.23' "$target_version"; then
		local option_package option_compression
		option_package=$(option_value 'package')
		option_compression=$(option_value 'compression')
		case "$option_package" in
			('arch')
				case "$option_compression" in
					('none'|'speed'|'size')
						# Valid combination (current value)
					;;
					('gzip'|'xz'|'bzip2'|'zstd')
						# Valid combination (legacy value)
					;;
					(*)
						error_incompatible_options 'package' 'compression'
						return 1
					;;
				esac
			;;
			('deb')
				case "$option_compression" in
					('none'|'speed'|'size')
						# Valid combination (current value)
					;;
					('gzip'|'xz')
						# Valid combination (legacy value)
					;;
					(*)
						error_incompatible_options 'package' 'compression'
						return 1
					;;
				esac
			;;
			('gentoo')
				case "$option_compression" in
					('none'|'speed'|'size')
						# Valid combination (current value)
					;;
					('gzip'|'xz'|'bzip2'|'zstd'|'lz4'|'lzip'|'lzop')
						# Valid combination (legacy value)
					;;
					(*)
						error_incompatible_options 'package' 'compression'
						return 1
					;;
				esac
			;;
			('egentoo')
				case "$option_compression" in
					('none'|'speed'|'size')
						# Valid combination (current value)
					;;
					('gzip'|'xz'|'bzip2'|'zstd'|'lzip')
						# Valid combination (legacy value)
					;;
					(*)
						error_incompatible_options 'package' 'compression'
						return 1
					;;
				esac
			;;
		esac
	fi
}
