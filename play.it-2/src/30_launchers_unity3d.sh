# Unity3D native game launcher - Run the game
# USAGE: launcher_write_script_unity3d_run $application $launcher_file
launcher_write_script_unity3d_run() {
	# shellcheck disable=SC2039
	local application launcher_file
	application="$1"
	launcher_file="$2"

	cat >> "$launcher_file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF

	launcher_write_script_prerun "$application" "$launcher_file"

	# Set path to extra libraries
	case "$OPTION_PACKAGE" in
		###
		# TODO
		# Check that the Gentoo special case is useful for Unity3D games
		###
		('gentoo'|'egentoo')
			cat >> "$launcher_file" <<- 'EOF'
			library_path=
			if [ -n "$APP_LIBS" ]; then
			    library_path="$APP_LIBS:"
			fi
			EOF
			if [ -n "$(launcher_native_get_extra_library_path)" ]; then
				cat >> "$launcher_file" <<- EOF
				library_path="\${library_path}$(launcher_native_get_extra_library_path)"
				EOF
			fi
			cat >> "$launcher_file" <<- 'EOF'
			if [ -n "$library_path" ]; then
			    LD_LIBRARY_PATH="${library_path}$LD_LIBRARY_PATH"
			    export LD_LIBRARY_PATH
			fi
			EOF
		;;
		(*)
			cat >> "$launcher_file" <<- 'EOF'
			if [ -n "$APP_LIBS" ]; then
			    export LD_LIBRARY_PATH="${APP_LIBS}:${LD_LIBRARY_PATH}"
			fi
			EOF
		;;
	esac

	cat >> "$launcher_file" <<- 'EOF'
	set +o errexit
	# shellcheck disable=SC2086
	"./$APP_EXE" $APP_OPTIONS "$@"
	set -o errexit

	EOF

	launcher_write_script_postrun "$application" "$launcher_file"

	sed --in-place 's/    /\t/g' "$launcher_file"
	return 0
}

