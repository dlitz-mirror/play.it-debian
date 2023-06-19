# Print the path to the engine file including the Unity3D build version
# USAGE: unity3d_version_file $file_name
# RETURN: the path to the engine file including the build version string
unity3d_version_file() {
	local file_name
	file_name="$1"

	local unity3d_name engine_info_file
	unity3d_name=$(unity3d_name)
	engine_info_file="${unity3d_name}_Data/${file_name}"

	# Look for the engine file in the temporary path for archive content.
	local content_path engine_info_file_path
	content_path=$(content_path_default)
	engine_info_file_path="${PLAYIT_WORKDIR}/gamedata/${content_path}/${engine_info_file}"
	if [ -f "$engine_info_file_path" ]; then
		printf '%s' "$engine_info_file_path"
		return 0
	fi

	# Look for the engine file in the current package.
	local package package_path path_game_data
	package=$(context_package)
	package_path=$(package_path "$package")
	path_game_data=$(path_game_data)
	engine_info_file_path="${package_path}${path_game_data}/${engine_info_file}"
	if [ -f "$engine_info_file_path" ]; then
		printf '%s' "$engine_info_file_path"
		return 0
	fi

	# Look for the engine file in all packages.
	local packages_list
	packages_list=$(packages_get_list)
	for package in $packages_list; do
		package_path=$(package_path "$package")
		engine_info_file_path="${package_path}${path_game_data}/${engine_info_file}"
		if [ -f "$engine_info_file_path" ]; then
			printf '%s' "$engine_info_file_path"
			return 0
		fi
	done
}

# Print the Unity3D build version for the current game
# USAGE: unity3d_version
# RETURN: the build version string
unity3d_version() {
	# Find the engine file including the build version string.
	local engine_info_file_path
	## Recent Unity3D releases stores the build version string in a file named "globalgamemanagers".
	engine_info_file_path=$(unity3d_version_file 'globalgamemanagers')
	if [ -z "$engine_info_file_path" ]; then
		## Old Unity3D releases stores the build version string in a file named "mainData".
		engine_info_file_path=$(unity3d_version_file 'mainData')
	fi

	# Return early if the engine data file including the build version string could not be found.
	if [ -z "$engine_info_file_path" ]; then
		return 0
	fi

	strings "$engine_info_file_path" | head --lines=1
}
