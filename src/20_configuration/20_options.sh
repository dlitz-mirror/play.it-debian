# Set default values for all options
# USAGE: options_init_default
options_init_default() {
	# Try to guess the desired package format based on the host system
	local default_package_format
	## Get system codename.
	local host_system
	if [ -e '/etc/os-release' ]; then
		host_system=$(grep '^ID=' '/etc/os-release' | cut --delimiter='=' --fields=2)
	elif command -v lsb_release >/dev/null 2>&1; then
		host_system=$(lsb_release --id --short | tr '[:upper:]' '[:lower:]')
	fi
	## Set the most appropriate package type for the current system.
	case "${host_system:-}" in
		( \
			'debian' | \
			'ubuntu' | \
			'linuxmint' | \
			'handylinux' \
		)
			default_package_format='deb'
		;;
		( \
			'arch' | \
			'artix' | \
			'manjaro' | \
			'manjarolinux' | \
			'endeavouros' | \
			'steamos' \
		)
			default_package_format='arch'
		;;
		( \
			'gentoo' \
		)
			default_package_format='gentoo'
		;;
	esac

	# Using a direct export call here instead of relying on option_update_default
	# massively improves performances when running a lot of ./play.it calls,
	# like what is done by the --list-supported-games option.
	export \
		PLAYIT_DEFAULT_OPTION_CHECKSUM='md5' \
		PLAYIT_DEFAULT_OPTION_COMPRESSION='none' \
		PLAYIT_DEFAULT_OPTION_OUTPUT_DIR="$PWD" \
		PLAYIT_DEFAULT_OPTION_PACKAGE="${default_package_format:-deb}" \
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

# Check the validity of all options
# USAGE: options_validity_check
# RETURN: nothing if all option values are valid,
#         throw an error otherwise
options_validity_check() {
	local option_checksum
	option_checksum=$(option_value 'checksum')
	case "$option_checksum" in
		('md5'|'none') ;;
		(*)
			error_option_invalid 'checksum' "$option_checksum"
			return 1
		;;
	esac

	local option_compression
	option_compression=$(option_value 'compression')
	case "$option_compression" in
		('none'|'speed'|'size'|'auto') ;;
		(*)
			error_option_invalid 'compression' "$option_compression"
			return 1
		;;
	esac

	local option_debug
	option_debug=$(option_value 'debug')
	case "$option_debug" in
		([0-9]) ;;
		(*)
			error_option_invalid 'debug' "$option_debug"
			return 1
		;;
	esac

	local option_free_space_check
	option_free_space_check=$(option_value 'free-space-check')
	case "$option_free_space_check" in
		(0|1) ;;
		(*)
			error_option_invalid 'free-space-check' "$option_free_space_check"
			return 1
		;;
	esac

	local option_help
	option_help=$(option_value 'help')
	case "$option_help" in
		(0|1) ;;
		(*)
			error_option_invalid 'help' "$option_help"
			return 1
		;;
	esac

	local option_icons
	option_icons=$(option_value 'icons')
	case "$option_icons" in
		(0|1) ;;
		(*)
			error_option_invalid 'icons' "$option_icons"
			return 1
		;;
	esac

	local option_list_available_scripts
	option_list_available_scripts=$(option_value 'list-available-scripts')
	case "$option_list_available_scripts" in
		(0|1) ;;
		(*)
			error_option_invalid 'list-available-scripts' "$option_list_available_scripts"
			return 1
		;;
	esac

	local option_list_packages
	option_list_packages=$(option_value 'list-packages')
	case "$option_list_packages" in
		(0|1) ;;
		(*)
			error_option_invalid 'list-packages' "$option_list_packages"
			return 1
		;;
	esac

	local option_list_requirements
	option_list_requirements=$(option_value 'list-requirements')
	case "$option_list_requirements" in
		(0|1) ;;
		(*)
			error_option_invalid 'list-requirements' "$option_list_requirements"
			return 1
		;;
	esac

	local option_list_supported_games
	option_list_supported_games=$(option_value 'list-supported-games')
	case "$option_list_supported_games" in
		(0|1) ;;
		(*)
			error_option_invalid 'list-supported-games' "$option_list_supported_games"
			return 1
		;;
	esac

	local option_mtree
	option_mtree=$(option_value 'mtree')
	case "$option_mtree" in
		(0|1) ;;
		(*)
			error_option_invalid 'mtree' "$option_mtree"
			return 1
		;;
	esac

	local option_output_dir
	option_output_dir=$(option_value 'output-dir')
	# Check that the value of "output-dir" is a path to a writable directory.
	## This check is not useful if a no-op option has been set.
	local noop_option noop_option_value noop_option_set
	noop_option_set=0
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
		if [ "$noop_option_value" -eq 1 ]; then
			noop_option_set=1
			break
		fi
	done
	if [ "$noop_option_set" = 0 ]; then
		local output_dir_path
		output_dir_path=$(printf '%s' "$option_output_dir" | sed "s#^~/#${HOME}/#")
		if [ ! -d "$output_dir_path" ]; then
			error_not_a_directory "$output_dir_path"
			return 1
		fi
		if [ ! -w "$output_dir_path" ]; then
			error_not_writable "$output_dir_path"
			return 1
		fi
	fi

	local option_overwrite
	option_overwrite=$(option_value 'overwrite')
	case "$option_overwrite" in
		(0|1) ;;
		(*)
			error_option_invalid 'overwrite' "$option_overwrite"
			return 1
		;;
	esac

	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch'|'deb'|'gentoo'|'egentoo') ;;
		(*)
			error_option_invalid 'package' "$option_package"
			return 1
		;;
	esac

	local option_prefix
	option_prefix=$(option_value 'prefix')
	# Check that the value of "prefix" is representing an absolute path.
	if printf '%s' "$option_prefix" | grep --quiet --invert-match --regexp '^/'; then
		return 0
	fi

	local option_show_game_script
	option_show_game_script=$(option_value 'show-game-script')
	case "$option_show_game_script" in
		(0|1) ;;
		(*)
			error_option_invalid 'show-game-script' "$option_show_game_script"
			return 1
		;;
	esac

	local option_tmpdir
	option_tmpdir=$(option_value 'tmpdir')
	# Check that the value of "tmpdir" is a path to a writable directory.
	## This check is not useful if a no-op option has been set.
	local noop_option noop_option_value noop_option_set
	noop_option_set=0
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
		if [ "$noop_option_value" -eq 1 ]; then
			noop_option_set=1
			break
		fi
	done
	if [ "$noop_option_set" = 0 ]; then
		local tmpdir_path
		tmpdir_path=$(printf '%s' "$option_tmpdir" | sed "s#^~/#${HOME}/#")
		if [ ! -d "$tmpdir_path" ]; then
			error_not_a_directory "$tmpdir_path"
			return 1
		fi
		if [ ! -w "$tmpdir_path" ]; then
			error_not_writable "$tmpdir_path"
			return 1
		fi
	fi

	local option_version
	option_version=$(option_value 'version')
	case "$option_version" in
		(0|1) ;;
		(*)
			error_option_invalid 'version' "$option_version"
			return 1
		;;
	esac
}

# Check the compatibility of all set options
# USAGE: options_compatibility_check
# RETURN: nothing if all the current options are valid used together,
#         throw an error otherwise
options_compatibility_check() {
	# Check the compatibility of --compression auto with the target package format.
	local option_compression
	option_compression=$(option_value 'compression')
	case "$option_compression" in
		('none')
			local option_package
			option_package=$(option_value 'package')
			case "$option_package" in
				('gentoo')
					# --compression none has not been implemented for Gentoo packages yet.
					error_incompatible_options 'package' 'compression'
					return 1
				;;
			esac
		;;
		('auto')
			local option_package
			option_package=$(option_value 'package')
			case "$option_package" in
				('arch')
					# --compression auto has not been implemented for Arch Linux packages yet.
					error_incompatible_options 'package' 'compression'
					return 1
				;;
			esac
		;;
	esac
}

