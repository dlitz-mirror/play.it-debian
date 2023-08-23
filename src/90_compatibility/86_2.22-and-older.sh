# Keep compatibility with 2.22 and older

package_provide_legacy() {
	local package
	package="$1"

	local package_provide
	package_provide=$(context_value "${package}_PROVIDE")

	# Return early if no alternative package name is provided by the current package.
	if [ -z "$package_provide" ]; then
		return 0
	fi

	# Apply Gentoo-specific tweaks.
	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('gentoo'|'egentoo')
			package_provide=$(gentoo_package_provide_legacy "$package_provide")
		;;
	esac

	printf '%s' "$package_provide"
}

gentoo_package_provide_legacy() {
	local provided_package_id
	provided_package_id="$1"

	# Avoid mixups between numbers in package ID and version number.
	provided_package_id=$(gentoo_package_id "$provided_package_id")

	# Add the required "!games-playit/" prefix to the package ID.
	printf '!games-playit/%s' "$provided_package_id"
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

