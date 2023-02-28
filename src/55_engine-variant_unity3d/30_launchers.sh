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
