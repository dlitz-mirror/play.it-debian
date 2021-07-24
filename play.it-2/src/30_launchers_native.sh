# native - write application-specific variables
# USAGE: launcher_write_script_native_application_variables $application $file
# CALLED BY: launcher_write_script
launcher_write_script_native_application_variables() {
	# shellcheck disable=SC2039
	local application file
	application="$1"
	file="$2"

	cat >> "$file" <<- EOF
	# Set application-specific values

	APP_EXE='$(application_exe "$application")'
	APP_LIBS='$(application_libs "$application")'
	APP_OPTIONS="$(application_options "$application")"

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
# NEEDED VARS: OPTION_PACKAGE
# CALLED BY: launcher_write_script_native_run_common
launcher_native_get_extra_library_path() {
	# get the current package
	local package
	package=$(package_get_current)

	if [ "$OPTION_PACKAGE" = 'gentoo' ] && get_value "${package}_DEPS" | sed --regexp-extended 's/\s+/\n/g' | grep --fixed-strings --line-regexp --quiet 'libcurl-gnutls'; then
		# Get package architecture
		# shellcheck disable=SC2039
		local pkg_architecture
		pkg_architecture=$(package_get_architecture_string "$PKG")

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
