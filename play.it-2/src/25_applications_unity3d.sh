# compute the file name of game binary from the UNITY3D_NAME value
# USAGE: application_unity3d_exe application
# RETURN: the application file name,
#         or an empty string
application_unity3d_exe() {
	# Check that the application uses the unity3d type
	local application application_type
	application="$1"
	application_type=$(application_type "$application")
	if [ "$application_type" != 'unity3d' ]; then
		error_application_wrong_type 'application_unity3d_exe' "$application_type"
		return 1
	fi

	# Return early if UNITY3D_NAME is not set
	if [ -z "$(unity3d_name)" ]; then
		return 0
	fi

	# Compute the file name from the package architecture and UNITY3D_NAME
	local architecture_suffix
	case "$(package_get_architecture "$(package_get_current)")" in
		('32')
			architecture_suffix='.x86'
		;;
		('64')
			architecture_suffix='.x86_64'
		;;
	esac
	printf '%s%s' "$(unity3d_name)" "$architecture_suffix"
}

