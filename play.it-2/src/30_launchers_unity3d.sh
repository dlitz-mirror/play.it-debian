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

	# Start pulseaudio if it is available
	launcher_unity3d_pulseaudio_start >> "$launcher_file"

	# Work around crash on launch related to libpulse
	# Some Unity3D games crash on launch if libpulse-simple.so.0 is available but pulseaudio is not running
	launcher_unity3d_pulseaudio_hide_libpulse >> "$launcher_file"

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

	# Stop pulseaudio if it has been started for this game session
	launcher_unity3d_pulseaudio_stop >> "$launcher_file"

	launcher_write_script_postrun "$application" "$launcher_file"

	sed --in-place 's/    /\t/g' "$launcher_file"
	return 0
}

# print the snippet starting pulseaudio if it is available
# USAGE: launcher_unity3d_pulseaudio_start
# RETURN: the code snippet, a multi-lines string, indented with four spaces
launcher_unity3d_pulseaudio_start() {
	cat <<- 'EOF'
	# Start pulseaudio if it is available
	pulseaudio_is_available() {
	    command -v pulseaudio >/dev/null 2>&1
	}
	if pulseaudio_is_available; then
	    if ! pulseaudio --check; then
	        touch .stop_pulseaudio_on_exit
	    fi
	    pulseaudio --start
	fi

	EOF
}

# print the snippet stopping pulseaudio if it has been started for this game session
# USAGE: launcher_unity3d_pulseaudio_stop
# RETURN: the code snippet, a multi-lines string, indented with four spaces
launcher_unity3d_pulseaudio_stop() {
	cat <<- 'EOF'
	# Stop pulseaudio if it has been started for this game session
	if [ -e .stop_pulseaudio_on_exit ]; then
	    pulseaudio --kill
	    rm .stop_pulseaudio_on_exit
	fi

	EOF
}

# print the snippet hiding libpulse-simple.so.0 if pulseaudio is not available
# USAGE: launcher_unity3d_pulseaudio_hide_libpulse
# RETURN: the code snippet, a multi-lines string, indented with four spaces
launcher_unity3d_pulseaudio_hide_libpulse() {
	cat <<- 'EOF'
	# Work around crash on launch related to libpulse
	# Some Unity3D games crash on launch if libpulse-simple.so.0 is available but pulseaudio is not running
	LIBPULSE_NULL_LINK="${APP_LIBS:=libs}/libpulse-simple.so.0"
	if pulseaudio_is_available; then
	    rm --force "$LIBPULSE_NULL_LINK"
	else
	    mkdir --parents "$(dirname "$LIBPULSE_NULL_LINK")"
	    ln --force --symbolic /dev/null "$LIBPULSE_NULL_LINK"
	fi

	EOF
}

