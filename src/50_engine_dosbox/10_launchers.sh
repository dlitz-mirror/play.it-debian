# DOSBox launcher - Print the script content
# USAGE: dosbox_launcher $application
dosbox_launcher() {
	local application
	application="$1"

	local prefix_type
	prefix_type=$(application_prefix_type "$application")
	case "$prefix_type" in
		('symlinks')
			launcher_headers
			dosbox_launcher_environment "$application"

			# Generate the game prefix
			launcher_print_persistent_paths
			launcher_prefix_symlinks_functions
			launcher_prefix_symlinks_build

			dosbox_launcher_run "$application"
			launcher_prefix_symlinks_cleanup
			launcher_exit
		;;
		(*)
			error_launchers_prefix_type_unsupported "$application"
			return 1
		;;
	esac
}

# DOSBox launcher - Set the environment
# USAGE: dosbox_launcher_environment $application
dosbox_launcher_environment() {
	local application
	application="$1"

	local game_id path_game application_exe application_options
	game_id=$(game_id)
	path_game=$(path_game_data)
	application_exe=$(application_exe_escaped "$application")
	application_options=$(application_options "$application")

	cat <<- EOF
	# Set the environment

	GAME_ID='$game_id'
	PATH_GAME='$path_game'
	APP_EXE='$application_exe'
	APP_OPTIONS="$application_options"

	EOF
}

# DOSBox launcher - Run DOSBox
# USAGE: dosbox_launcher_run $application
dosbox_launcher_run() {
	local application
	application="$1"

	local application_prerun application_postrun dosbox_instructions
	application_prerun=$(application_prerun "$application")
	application_postrun=$(application_postrun "$application")
	dosbox_instructions=$(dosbox_launcher_instructions "$application")

	cat <<- EOF
	# Run the game

	cd "\$PATH_PREFIX"

	$application_prerun

	## Do not exit on application failure,
	## to ensure post-run commands are run.
	set +o errexit

	## Silence ShellCheck false-positive
	## Argument mixes string and array. Use * or separate argument.
	# shellcheck disable=SC2145
	"\${PLAYIT_DOSBOX_BINARY:-dosbox}" -c "$dosbox_instructions"

	game_exit_status=\$?
	set -o errexit

	$application_postrun

	EOF
}

# DOSBox launcher - Run commands inside DOSBox
# USAGE: dosbox_launcher_instructions $application
dosbox_launcher_instructions() {
	local application
	application="$1"

	# Compute the command used to mount the disk image
	if [ -n "${GAME_IMAGE:-}" ]; then
		# Find the disk image path
		local packages_list path_game_data
		packages_list=$(packages_get_list)
		path_game_data=$(path_game_data)
		## Loop over the list of packages, one should include the disk image.
		local package package_path image_path disk_image
		for package in $packages_list; do
			package_path=$(package_path "$package")
			image_path="${package_path}${path_game_data}/${GAME_IMAGE}"
			if [ -e "$image_path" ]; then
				disk_image="$image_path"
				break
			fi
		done
		## Exit with a failure state if the disk image has not been found.
		if [ -z "${disk_image:-}" ]; then
			error_dosbox_disk_image_no_found "$GAME_IMAGE"
			return 1
		fi

		# Set the command used to mount the disk image, based on its type
		local mount_disk_image
		case "${GAME_IMAGE_TYPE:-iso}" in
			('cdrom')
				if [ -d "$disk_image" ]; then
					mount_disk_image="mount d $GAME_IMAGE -t cdrom"
				else
					mount_disk_image="imgmount d $GAME_IMAGE -t cdrom"
				fi
			;;
			('iso')
				mount_disk_image="imgmount d $GAME_IMAGE -t iso -fs iso"
			;;
		esac
	fi

	local dosbox_prerun dosbox_postrun
	dosbox_prerun=$(dosbox_prerun "$application")
	dosbox_postrun=$(dosbox_postrun "$application")

	cat <<- EOF
	mount c .
	c:
	EOF
	if [ -n "${mount_disk_image:-}" ]; then
		cat <<- EOF
		$mount_disk_image
		EOF
	fi
	if [ -n "$dosbox_prerun" ]; then
		cat <<- EOF
		$dosbox_prerun
		EOF
	fi
	cat <<- 'EOF'
	$APP_EXE $APP_OPTIONS $@
	EOF
	if [ -n "$dosbox_postrun" ]; then
		cat <<- EOF
		$dosbox_postrun
		EOF
	fi
	cat <<- EOF
	exit
	EOF
}
