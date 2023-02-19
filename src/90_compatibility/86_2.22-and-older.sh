# Keep compatibility with 2.22 and older

debian_dpkg_compression_legacy() {
	local dpkg_options option_compression
	dpkg_options="$1"
	option_compression="$2"

	printf '%s -Z%s' "$dpkg_options" "$option_compression"
}

archlinux_tar_compress_program_legacy() {
	local option_compression
	option_compression="$1"

	printf '%s' "$option_compression"
}

archlinux_package_name_legacy() {
	local package_name option_compression
	package_name="$1"
	option_compression="$2"

	case "$option_compression" in
		('gzip')
			package_name="${package_name}.gz"
		;;
		('xz')
			package_name="${package_name}.xz"
		;;
		('bzip2')
			package_name="${package_name}.bz2"
		;;
		('zstd')
			package_name="${package_name}.zst"
		;;
	esac

	printf '%s' "$package_name"
}

gentoo_package_binkpg_compress_legacy() {
	local option_compression
	option_compression="$1"

	printf '%s' "$option_compression"
}

egentoo_package_name_legacy() {
	local package_name option_compression
	package_name="$1"
	option_compression="$2"

	case "$option_compression" in
		('gzip')
			package_name="${package_name}.gz"
		;;
		('xz')
			package_name="${package_name}.xz"
		;;
		('bzip2')
			package_name="${package_name}.bz2"
		;;
		('zstd')
			package_name="${package_name}.zst"
		;;
		('lzip')
			package_name="${package_name}.lz"
		;;
	esac

	printf '%s' "$package_name"
}

egentoo_package_inherits_legacy() {
	local package_inherits option_compression
	package_inherits="$1"
	option_compression="$2"

	case "$option_compression" in
		('zstd')
			package_inherits="$package_inherits unpacker"
		;;
		('lzip')
			package_inherits="$package_inherits unpacker"
		;;
	esac

	printf '%s' "$package_inherits"
}

egentoo_package_build_deps_legacy() {
	local package_build_deps option_compression
	package_build_deps="$1"
	option_compression="$2"

	case "$option_compression" in
		('zstd')
			package_build_deps="$build_deps\\n\\t\$(unpacker_src_uri_depends)"
		;;
		('lzip')
			package_build_deps="$build_deps\\n\\t\$(unpacker_src_uri_depends)"
		;;
	esac

	printf '%s' "$package_build_deps"
}

egentoo_package_compression_command_legacy() {
	local package_compression_command option_compression
	package_compression_command="$1"
	option_compression="$2"

	case "$option_compression" in
		('gzip')
			package_compression_command='gzip'
		;;
		('xz')
			package_compression_command='xz'
		;;
		('bzip2')
			package_compression_command='bzip2'
		;;
		('zstd')
			package_compression_command='zstd'
		;;
		('lzip')
			package_compression_command=$(get_lzip_implementation)
			if [ "$package_compression_command" = 'tarlz' ]; then
				package_compression_command=''
				export PLAYIT_TAR_IMPLEMENTATION='gnutar'
			fi
		;;
	esac

	printf '%s' "$package_compression_command"
}

egentoo_package_compression_options_legacy() {
	local package_compression_options option_compression
	package_compression_options="$1"
	option_compression="$2"

	case "$option_compression" in
		('xz')
			package_compression_options='--threads=0'
		;;
		('lzip')
			local package_compression_command
			package_compression_command=$(get_lzip_implementation)
			if [ "$package_compression_command" != 'tarlz' ]; then
				package_compression_options='-0'
			fi
		;;
	esac

	printf '%s' "$package_compression_options"
}

egentoo_package_tar_command_legacy() {
	local package_tar_command option_compression
	package_tar_command="$1"
	option_compression="$2"

	case "$option_compression" in
		('lzip')
			local package_compression_command
			package_compression_command=$(get_lzip_implementation)
			if [ "$package_compression_command" = 'tarlz' ]; then
				package_tar_command='tarlz'
				export PLAYIT_TAR_IMPLEMENTATION='gnutar'
			fi
		;;
	esac

	printf '%s' "$package_tar_command"
}

option_validity_check_compression_legacy() {
	local option_value
	option_value="$1"

	case "$option_value" in
		( \
			'bzip2' | \
			'gzip' | \
			'lz4' | \
			'lzip' | \
			'lzop' | \
			'none' | \
			'xz' | \
			'zstd' \
		)
			return 0
		;;
	esac

	# Throw an error if we are not in one of the valid cases
	error_option_invalid 'compression' "$option_value"
	return 1
}

option_export_legacy() {
	local option_name
	option_name="$1"

	local option_value
	option_value=$(option_value "$option_name")
	case "$option_name" in
		('checksum')
			export OPTION_CHECKSUM="$option_value"
		;;
		('compression')
			export OPTION_COMPRESSION="$option_value"
		;;
		('debug')
			export DEBUG="$option_value"
		;;
		('free-space-check')
			case "$option_value" in
				(0)
					export NO_FREE_SPACE_CHECK=1
				;;
				(1)
					export NO_FREE_SPACE_CHECK=0
				;;
			esac
		;;
		('icons')
			case "$option_value" in
				(0)
					export OPTION_ICONS='no'
				;;
				(1)
					export OPTION_ICONS='yes'
				;;
			esac
		;;
		('list-packages')
			export PRINT_LIST_OF_PACKAGES="$option_value"
		;;
		('list-requirements')
			export PRINT_REQUIREMENTS="$option_value"
		;;
		('mtree')
			export MTREE="$option_value"
		;;
		('output-dir')
			export OPTION_OUTPUT_DIR="$option_value"
		;;
		('overwrite')
			export OVERWRITE_PACKAGES="$option_value"
		;;
		('package')
			export OPTION_PACKAGE="$option_value"
		;;
		('prefix')
			export OPTION_PREFIX="$option_value"
		;;
	esac
}
