# Keep compatibility with 2.22 and older

option_validity_check_compression_legacy() {
	local option_value
	option_value="$1"

	local option_package option_package_variable
	option_package_variable=$(option_variable 'package')
	option_package=$(get_value "$option_package_variable")
	case "$option_package" in
		('arch')
			case "$option_value" in
				('none'|'gzip'|'xz'|'bzip2'|'zstd')
					return 0
				;;
			esac
		;;
		('deb')
			case "$option_value" in
				('none'|'gzip'|'xz')
					return 0
				;;
			esac
		;;
		('gentoo')
			case "$option_value" in
				('gzip'|'xz'|'bzip2'|'zstd'|'lz4'|'lzip'|'lzop')
					return 0
				;;
			esac
		;;
		('egentoo')
			case "$option_value" in
				('none'|'gzip'|'xz'|'bzip2'|'zstd'|'lzip')
					return 0
				;;
			esac
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
