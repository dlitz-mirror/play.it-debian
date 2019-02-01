# native - write application-specific variables
# USAGE: launcher_write_script_native_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_native_application_variables() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	# compute application-specific variables values
	local application_exe
	local application_libs
	local application_options
	use_package_specific_value "${application}_EXE"
	use_package_specific_value "${application}_LIBS"
	use_package_specific_value "${application}_OPTIONS"
	application_exe="$(get_value "${application}_EXE")"
	application_libs="$(get_value "${application}_LIBS")"
	application_options="$(get_value "${application}_OPTIONS")"

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

# native - get extra LD_LIBRARY_PATH entries (with a trailing :)
# USAGE: launcher_native_get_extra_library_path
# NEEDED VARS: OPTION_PACKAGE PKG
# CALLED BY: launcher_write_script_native_run_common
launcher_native_get_extra_library_path() {
	if [ "$OPTION_PACKAGE" = 'gentoo' ] && get_value "${PKG}_DEPS" | sed --regexp-extended 's/\s+/\n/g' | grep --fixed-strings --line-regexp --quiet 'libcurl-gnutls'; then
		local pkg_architecture
		set_architecture "$PKG"
		printf '%s' "/usr/\$(portageq envvar 'LIBDIR_$pkg_architecture')/debiancompat:"
	fi
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
	"./$APP_EXE" $APP_OPTIONS $@

	EOF

	launcher_write_script_postrun "$application" "$file"

	sed --in-place 's/    /\t/g' "$file"
	return 0
}
