# Gentoo - Native Linux launchers - Get extra LD_LIBRARY_PATH entries (with a trailing :)
# USAGE: launcher_native_get_extra_library_path
launcher_native_get_extra_library_path() {
	# Do nothing if we are not building packages for Gentoo
	case "$OPTION_PACKAGE" in
		('gentoo')
			# Keep going on
		;;
		(*)
			return 0
		;;
	esac

	local package
	package=$(package_get_current)
	if \
		dependencies_list_generic "$package" | \
			grep --fixed-strings --line-regexp --quiet 'libcurl-gnutls'
	then
		local package_architecture
		package_architecture=$(package_get_architecture_string "$package")
		printf '%s' "/usr/\$(portageq envvar 'LIBDIR_${package_architecture}')/debiancompat:"
	fi
}
