# DOSBox - write application-specific variables
# USAGE: launcher_write_script_dosbox_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_dosbox_application_variables() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	# compute application-specific variables values
	local application_exe
	local application_options
	use_package_specific_value "${application}_EXE"
	use_package_specific_value "${application}_OPTIONS"
	application_exe="$(get_value "${application}_EXE")"
	application_options="$(get_value "${application}_OPTIONS")"

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
				local package

				# Get packages list for the current game
				local packages_list
				packages_list=$(packages_get_list)

				for package in $packages_list; do
					if [ -e "$(package_get_path "$package")$PATH_GAME/$GAME_IMAGE" ]; then
						image="$(package_get_path "$package")$PATH_GAME/$GAME_IMAGE"
						break;
					fi
				done
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

