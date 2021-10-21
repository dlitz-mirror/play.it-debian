# DOSBox - write application-specific variables
# USAGE: launcher_write_script_dosbox_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_dosbox_application_variables() {
	local application file
	application="$1"
	file="$2"
	local application_exe application_options
	application_exe=$(application_exe "$application")
	application_options=$(application_options "$application")

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$application_exe'
	APP_OPTIONS="$application_options"

	EOF
	return 0
}

# DOSBox - run the game
# USAGE: launcher_write_script_dosbox_run $application $file
# NEEDED_VARS: GAME_IMAGE GAME_IMAGE_TYPE PATH_GAME
# CALLS: launcher_write_script_prerun launcher_write_script_postrun
# CALLED BY: launcher_write_script
launcher_write_script_dosbox_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"
	"${PLAYIT_DOSBOX_BINARY:-dosbox}" -c "mount c .
	c:
	EOF

	# mount CD image file
	if [ "$GAME_IMAGE" ]; then
		case "$GAME_IMAGE_TYPE" in
			('cdrom')
				local image
				unset image

				# Loop over the list of packages, one should include the disk image
				local package package_path packages_list
				packages_list=$(packages_get_list)
				for package in $packages_list; do
					package_path=$(package_get_path "$package")
					if [ -e "${package_path}$PATH_GAME/$GAME_IMAGE" ]; then
						image="${package_path}$PATH_GAME/$GAME_IMAGE"
						break;
					fi
				done

				###
				# TODO
				# If the disk image has not been found, an explicit error should be thrown.
				###

				if [ -d "$image" ]; then
					cat >> "$file" <<- EOF
					mount d $GAME_IMAGE -t cdrom
					EOF
				else
					cat >> "$file" <<- EOF
					imgmount d $GAME_IMAGE -t cdrom
					EOF
				fi
			;;
			('iso'|*)
				cat >> "$file" <<- EOF
				imgmount d $GAME_IMAGE -t iso -fs iso
				EOF
			;;
		esac
	fi

	launcher_write_script_prerun "$application" "$file"

	cat >> "$file" <<- 'EOF'
	$APP_EXE $APP_OPTIONS $@
	EOF

	launcher_write_script_postrun "$application" "$file"

	cat >> "$file" <<- 'EOF'
	exit"

	EOF
	return 0
}

