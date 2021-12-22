# Java - write application-specific variables
# USAGE: launcher_write_script_java_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_java_application_variables() {
	local application file
	application="$1"
	file="$2"
	local application_exe application_libs application_options application_java_options
	application_exe=$(application_exe_escaped "$application")
	application_libs=$(application_libs "$application")
	application_options=$(application_options "$application")
	application_java_options=$(application_java_options "$application")

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$application_exe'
	APP_LIBS='$application_libs'
	APP_OPTIONS="$application_options"
	JAVA_OPTIONS='$application_java_options'

	EOF
	return 0
}

# Java - run the game
# USAGE: launcher_write_script_java_run $application $file
# CALLED BY: launcher_write_script
launcher_write_script_java_run() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF

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
	JAVA_OPTIONS="$(eval printf -- '%b' \"$JAVA_OPTIONS\")"
	java $JAVA_OPTIONS -jar "$APP_EXE" $APP_OPTIONS "$@"

	EOF

	launcher_write_script_postrun "$application" "$file"

	sed --in-place 's/    /\t/g' "$file"
	return 0
}

