# Unity3D native game launcher - Run the game
# USAGE: launcher_write_script_unity3d_run $application $launcher_file
launcher_write_script_unity3d_run() {
	local application launcher_file
	application="$1"
	launcher_file="$2"

	cat >> "$launcher_file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF

	launcher_write_script_prerun "$application" "$launcher_file"

	# Include common pre-run tweaks
	# shellcheck disable=SC2129
	{
		# Start pulseaudio if it is available
		launcher_unity3d_pulseaudio_start

		# Work around crash on launch related to libpulse
		# Some Unity3D games crash on launch if libpulse-simple.so.0 is available but pulseaudio is not running
		launcher_unity3d_pulseaudio_hide_libpulse

		# Use a dedicated log file for the current game session
		launcher_unity3d_dedicated_log

		# Make a hard copy of the game binary in the current prefix,
		# otherwise the engine might follow the link and run the game from the system path.
		launcher_unity3d_copy_binary

		# Work around Unity3D poor support for non-US locales
		launcher_unity3d_force_locale
	} >> "$launcher_file"

	# Set loading paths for libraries
	launcher_native_libraries_paths >> "$launcher_file"

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
}

# Print the snippet starting pulseaudio if it is available
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

# Print the snippet stopping pulseaudio if it has been started for this game session
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

# Print the snippet hiding libpulse-simple.so.0 if pulseaudio is not available
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

# Print the snippet setting a dedicated log file for the current game session
# USAGE: launcher_unity3d_dedicated_log
# RETURN: the code snippet, a multi-lines string
launcher_unity3d_dedicated_log() {
	cat <<- 'EOF'
	# Use a dedicated log file for the current game session
	mkdir --parents logs
	APP_OPTIONS="${APP_OPTIONS} -logFile ./logs/$(date +%F-%R).log"

	EOF
}

# Print the snippet making a hard copy of the game binary in the prefix
# USAGE: launcher_unity3d_copy_binary
# RETURN: the code snippet, a multi-lines string, indented with four spaces
launcher_unity3d_copy_binary() {
	cat <<- 'EOF'
	# Make a hard copy of the game binary in the current prefix,
	# otherwise the engine might follow the link and run the game from the system path.
	if [ -h "$APP_EXE" ]; then
	    cp --remove-destination "$(realpath "$APP_EXE")" "$APP_EXE"
	fi

	EOF
}

# Print the snippet setting forcing the use of a US-like locale
# USAGE: launcher_unity3d_force_locale
# RETURN: the code snippet, a multi-lines string
launcher_unity3d_force_locale() {
	cat <<- 'EOF'
	# Work around Unity3D poor support for non-US locales
	export LANG=C

	EOF
}
