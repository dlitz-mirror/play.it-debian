# Compute the file name of the game binary from the UNITY3D_NAME value
# USAGE: unity3d_application_exe_default application
# RETURN: the application file name,
#         or an empty string
unity3d_application_exe_default() {
	local application
	application="$1"

	# We can not rely on the application type here,
	# to avoid a loop between application_exe and application_type.
	local unity3d_name
	unity3d_name=$(unity3d_name)
	local package package_architecture
	package=$(context_package)
	package_architecture=$(package_architecture "$package")
	local filename_candidates_list filename_candidate filename_path filename_found
	case "$package_architecture" in
		('32')
			filename_candidates_list="
			${unity3d_name}
			${unity3d_name}.x86
			${unity3d_name}.exe"
		;;
		('64')
			filename_candidates_list="
			${unity3d_name}
			${unity3d_name}.x86_64
			${unity3d_name}.exe"
		;;
		(*)
			filename_candidates_list="
			${unity3d_name}
			${unity3d_name}.x86
			${unity3d_name}.x86_64
			${unity3d_name}.exe"
		;;
	esac
	## Use a while loop to avoid breaking on spaces in file name.
	while read -r filename_candidate; do
		## Skip empty lines.
		if [ -z "$filename_candidate" ]; then
			continue
		fi
		filename_path=$(application_exe_path "$filename_candidate")
		if [ -n "$filename_path" ]; then
			filename_found="$filename_candidate"
			break
		fi
	done <<- EOL
	$(printf '%s' "$filename_candidates_list")
	EOL

	printf '%s' "${filename_found:-}"
}

