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
# CALLS: launcher_write_script_prerun launcher_write_script_postrun launcher_native_get_extra_library_path
# CALLED BY: launcher_write_script_native_run launcher_write_script_nativenoprefix_run
launcher_write_script_native_run_common() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	launcher_write_script_prerun "$application" "$file"

	# Set path to extra libraries
	case "$OPTION_PACKAGE" in
		('gentoo'|'egentoo')
			cat >> "$file" <<- 'EOF'
			library_path=
			if [ -n "$APP_LIBS" ]; then
			    library_path="$APP_LIBS:"
			fi
			EOF
			local extra_library_path
			extra_library_path="$(launcher_native_get_extra_library_path)"
			if [ -n "$extra_library_path" ]; then
				cat >> "$file" <<- EOF
				library_path="\${library_path}$extra_library_path"
				EOF
			fi
			cat >> "$file" <<- 'EOF'
			if [ -n "$library_path" ]; then
			    LD_LIBRARY_PATH="${library_path}$LD_LIBRARY_PATH"
			    export LD_LIBRARY_PATH
			fi
			EOF
		;;
		(*)
			cat >> "$file" <<- 'EOF'
			if [ -n "$APP_LIBS" ]; then
			    export LD_LIBRARY_PATH="${APP_LIBS}:${LD_LIBRARY_PATH}"
			fi
			EOF
		;;
	esac

	cat >> "$file" <<- 'EOF'
	"./$APP_EXE" $APP_OPTIONS "$@"

	EOF

	launcher_write_script_postrun "$application" "$file"

	sed --in-place 's/    /\t/g' "$file"
	return 0
}
