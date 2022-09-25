# native - write application-specific variables
# USAGE: launcher_write_script_native_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_native_application_variables() {
	local application file
	application="$1"
	file="$2"
	local application_exe application_libs application_options
	application_exe=$(application_exe_escaped "$application")
	application_libs=$(application_libs "$application")
	application_options=$(application_options "$application")

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$application_exe'
	APP_LIBS='$application_libs'
	APP_OPTIONS="$application_options"

	EOF
	return 0
}

# native - run the game (with prefix)
# USAGE: launcher_write_script_native_run $application $file
# CALLED BY: launcher_write_script
launcher_write_script_native_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Copy the game binary into the user prefix

	if [ -e "$PATH_DATA/$APP_EXE" ]; then
	    source_dir="$PATH_DATA"
	else
	    source_dir="$PATH_GAME"
	fi

	(
	    cd "$source_dir"
	    cp --parents --dereference --remove-destination "$APP_EXE" "$PATH_PREFIX"
	)

	# Run the game

	cd "$PATH_PREFIX"

	EOF
	sed --in-place 's/    /\t/g' "$file"

	launcher_write_script_native_run_common "$application" "$file"

	return 0
}

# native - run the game (without prefix)
# USAGE: launcher_write_script_nativenoprefix_run $application $file
# CALLED BY: launcher_write_script
launcher_write_script_nativenoprefix_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_GAME"

	EOF

	launcher_write_script_native_run_common "$application" "$file"

	return 0
}

# native - run the game (common part)
# USAGE: launcher_write_script_native_run_common $application $file
launcher_write_script_native_run_common() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	launcher_write_script_prerun "$application" "$file"

	# Set loading paths for libraries
	launcher_native_libraries_paths >> "$file"

	cat >> "$file" <<- 'EOF'
	"./$APP_EXE" $APP_OPTIONS "$@"

	EOF

	launcher_write_script_postrun "$application" "$file"

	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# Linux native - Print libraries loading path.
# USAGE: launcher_native_libraries_paths
launcher_native_libraries_paths() {
	local path_system
	path_system=$(path_libraries)
	assert_not_empty 'path_system' 'launcher_native_libraries_paths'

	local path_user
	path_user='${HOME}/.local/lib/games/${GAME_ID}'

	cat <<- EOF
	# Set loading paths for libraries
	PLAYIT_LIBS_PATH_LEGACY="\$APP_LIBS"
	PLAYIT_LIBS_PATH_SYSTEM='${path_system}'
	PLAYIT_LIBS_PATH_USER="${path_user}"
	EOF
	cat <<- 'EOF'
	if [ -n "$PLAYIT_LIBS_PATH_LEGACY" ]; then
	    LD_LIBRARY_PATH="${PLAYIT_LIBS_PATH_LEGACY}:${LD_LIBRARY_PATH}"
	fi
	if [ -e "$PLAYIT_LIBS_PATH_SYSTEM" ]; then
	    LD_LIBRARY_PATH="${PLAYIT_LIBS_PATH_SYSTEM}:${LD_LIBRARY_PATH}"
	fi
	if [ -e "$PLAYIT_LIBS_PATH_USER" ]; then
	    LD_LIBRARY_PATH="${PLAYIT_LIBS_PATH_USER}:${LD_LIBRARY_PATH}"
	fi
	export LD_LIBRARY_PATH
	EOF
}
