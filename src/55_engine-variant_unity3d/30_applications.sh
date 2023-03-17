# Compute the file name of the game binary from the UNITY3D_NAME value
# USAGE: application_unity3d_exe application
# RETURN: the application file name,
#         or an empty string
application_unity3d_exe() {
	local application
	application="$1"

	# Compute the file name from the package architecture and UNITY3D_NAME,
	# or return early if the current package is not supposed to include binaries.
	local package package_architecture architecture_suffix
	package=$(context_package)
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			architecture_suffix='.x86'
		;;
		('64')
			architecture_suffix='.x86_64'
		;;
		('all')
			return 0
		;;
	esac
	local unity3d_name
	unity3d_name=$(unity3d_name)
	printf '%s%s' "$unity3d_name" "$architecture_suffix"
}
