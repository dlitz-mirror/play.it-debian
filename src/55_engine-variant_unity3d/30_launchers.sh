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

# Print the snippet setting forcing the use of a US-like locale
# USAGE: launcher_unity3d_force_locale
# RETURN: the code snippet, a multi-lines string
launcher_unity3d_force_locale() {
	cat <<- 'EOF'
	# Work around Unity3D poor support for non-US locales
	export LANG=C

	EOF
}

# Disable the MAP_32BIT flag to prevent a crash one some Linux versions when running a 64-bit build of Unity3D
# USAGE: unity3d_disable_map32bit
# RETURN: the code snippet, a multi-lines string, indented with four spaces
unity3d_disable_map32bit() {
	# Check that the gcc command is available
	SCRIPT_DEPS="${SCRIPT_DEPS:-} gcc"
	check_deps

	local hack_source hack_library
	hack_source='hacks/disable-map32bit.c'
	hack_library="${hack_source%.c}.so"

	local package package_path path_game hack_source_path hack_library_path
	package=$(context_package)
	package_path=$(package_path "$package")
	path_game=$(path_game_data)
	hack_source_path="${package_path}${path_game}/${hack_source}"
	hack_library_path="${package_path}${path_game}/${hack_library}"

	local hack_directory
	hack_directory=$(dirname "$hack_source_path")
	mkdir --parents "$hack_directory"
	cat > "$hack_source_path" <<- 'EOF'
	#define _GNU_SOURCE
	#include <stdlib.h>
	#include <dlfcn.h>
	#include <sys/mman.h>

	typedef void *(*orig_mmap_type)(void *addr, size_t length, int prot,
	                                int flags, int fd, off_t offset);

	void *mmap(void *addr, size_t length, int prot, int flags,
	           int fd, off_t offset)
	{
	    static orig_mmap_type orig_mmap = NULL;
	    if (orig_mmap == NULL)
	        orig_mmap = (orig_mmap_type)dlsym(RTLD_NEXT, "mmap");

	    flags &= ~MAP_32BIT;

	    return orig_mmap(addr, length, prot, flags, fd, offset);
	}
	EOF

	gcc -Wall -shared "$hack_source_path" -o "$hack_library_path"

	cat <<- EOF
	# Disable the MAP_32BIT flag to prevent a crash one some Linux versions
	# when running a 64-bit build of Unity3D.
	export LD_PRELOAD="\${LD_PRELOAD:-}:${hack_library}"

	EOF
}
