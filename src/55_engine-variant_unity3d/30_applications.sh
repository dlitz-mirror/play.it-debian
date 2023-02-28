# Compute the file name of the game binary from the UNITY3D_NAME value
# USAGE: application_unity3d_exe application
# RETURN: the application file name,
#         or an empty string
application_unity3d_exe() {
	local application
	application="$1"

	local unity3d_name
	unity3d_name=$(unity3d_name)

	# FIXME - A critical error should be thrown if UNITY3D_NAME is not set.
	if [ -z "$unity3d_name" ]; then
		return 0
	fi

	# Compute the file name from the package architecture and UNITY3D_NAME.
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
	esac
	printf '%s%s' "$unity3d_name" "$architecture_suffix"
}
