# Print the list of native libraries required by a given package
# USAGE: dependencies_list_native_libraries $package
# RETURNS: a list of native library names,
#          one per line
dependencies_list_native_libraries() {
	local package
	package="$1"

	get_value "${package}_DEPENDENCIES_LIBRARIES"
}

# Print the list of native packages providing the native libraries required by a given package
# USAGE: dependencies_list_native_libraries_packages $package
# RETURNS: a list of native package names,
#          one per line
dependencies_list_native_libraries_packages() {
	local package package_architecture
	package="$1"
	package_architecture=$(package_get_architecture "$package")

	local required_native_libraries library
	required_native_libraries=$(dependencies_list_native_libraries "$package")
	for library in $required_native_libraries; do
		case "$OPTION_PACKAGE" in
			('arch')
				case "$package_architecture" in
					('32')
						dependency_package_providing_library_arch32 "$library"
					;;
					(*)
						dependency_package_providing_library_arch "$library"
					;;
				esac
			;;
			('deb')
				dependency_package_providing_library_deb "$library"
			;;
			('gentoo'|'egentoo')
				case "$package_architecture" in
					('32')
						dependency_package_providing_library_gentoo32 "$library"
					;;
					(*)
						dependency_package_providing_library_gentoo "$library"
					;;
				esac
			;;
		esac
		printf '\n'
	done | sort --unique
}
