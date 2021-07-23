# Mono - write application-specific variables
# USAGE: launcher_write_script_mono_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_mono_application_variables() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$(get_context_specific_value 'package' "${application}_EXE")'
	APP_LIBS='$(get_context_specific_value 'package' "${application}_MONO_OPTIONS")'
	APP_OPTIONS="$(get_context_specific_value 'package' "${application}_LIBS")"
	MONO_OPTIONS='$(get_context_specific_value 'package' "${application}_OPTIONS")'

	EOF
	return 0
}

# Mono - run the game
# USAGE: launcher_write_script_mono_run $application $file
# CALLED BY: launcher_write_script
launcher_write_script_mono_run() {
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
	# Work around terminfo Mono bug, cf. https://github.com/mono/mono/issues/6752
	export TERM="${TERM%-256color}"

	# Work around Mono unpredictable behaviour with non-US locales
	export LANG=C

	if [ -n "$library_path" ]; then
	    LD_LIBRARY_PATH="${library_path}$LD_LIBRARY_PATH"
	    export LD_LIBRARY_PATH
	fi
	MONO_OPTIONS="$(eval printf -- '%b' \"$MONO_OPTIONS\")"
	mono $MONO_OPTIONS "$APP_EXE" $APP_OPTIONS "$@"

	EOF

	launcher_write_script_postrun "$application" "$file"

	sed --in-place 's/    /\t/g' "$file"
	return 0
}

