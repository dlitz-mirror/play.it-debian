# Print function computing the path to the game prefix
# USAGE: prefix_function_prefix_path
prefix_function_prefix_path() {
	cat <<- 'EOF'
	# Compute the path to game prefix for the current session
	prefix_path() {
	    # Prefix path can be explicitely set using an environment variable
	    if [ -n "$PLAYIT_PREFIX_PATH" ]; then
	        printf '%s' "$PLAYIT_PREFIX_PATH"
	        return 0
	    fi
	    # Compute the default prefix path if none has been explicitely set
	    printf '%s/play.it/prefixes/%s' \
	        "${XDG_CACHE_HOME:="$HOME/.cache"}" \
	        "$GAME_ID"
	}
	EOF
}

# Populate prefix with symbolic links to all game files
# USAGE: prefix_generate_links_farm
prefix_generate_links_farm() {
	cat <<- 'EOF'
	# Populate prefix with symbolic links to all game files
	prefix_generate_links_farm() {
	    # Remove links to game directories
	    (
	        cd "$PATH_GAME"
	        find . -type d | while read -r directory; do
	            if [ -h "${PATH_PREFIX}/${directory}" ]; then
	                rm "${PATH_PREFIX}/${directory}"
	            fi
	        done
	    )
	    # Populate prefix with links to all game files.
	    cp \
	        --dereference --no-target-directory --recursive --remove-destination --symbolic-link \
	        "$PATH_GAME" "$PATH_PREFIX"
	    # Remove dangling links and non-game empty directories.
	    (
	        cd "$PATH_PREFIX"
	        find . -type l | while read -r link; do
	            if [ ! -e "$link" ]; then
	                rm "$link"
	            fi
	        done
	        find . -depth -type d | while read -r directory; do
	            if [ ! -e "${PATH_GAME}/${directory}" ]; then
	                rmdir --ignore-fail-on-non-empty "$directory"
	            fi
	        done
	    )
	}
	EOF
}

# print function creating and initializing the user prefix
# USAGE: launcher_prefix_function_build
launcher_prefix_function_build() {
	cat <<- 'EOF'
	# create and initialize user prefix
	# USAGE: prefix_build
	prefix_build() {
	    prefix_generate_links_farm
	    persistent_populate_prefix
	    persistent_init_directories
	    persistent_init_files
	}
	EOF
}

# write launcher script prefix functions
# USAGE: launcher_write_script_prefix_functions $file
# CALLED BY: launcher_write_script
launcher_write_script_prefix_functions() {
	local file
	file="$1"
	{
		cat <<- 'EOF'
		# Set userdir- and prefix-related functions
		EOF
		prefix_function_prefix_path
		launcher_prefix_functions_persistent
		prefix_generate_links_farm
		launcher_prefix_function_build
	} >> "$file"
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix prepare hook
# USAGE: launcher_write_script_prefix_prepare $file
launcher_write_script_prefix_prepare() {
	local file
	file="$1"

	if ! variable_is_empty 'PREFIX_PREPARE'; then
		cat >> "$file" <<- EOF
		$PREFIX_PREPARE

		EOF
	fi

	return 0
}

# write launcher script prefix initialization
# USAGE: launcher_write_script_prefix_build $file
# CALLED BY: launcher_write_build
launcher_write_script_prefix_build() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Build user prefix

	PATH_PREFIX=$(prefix_path)
	mkdir --parents \
	    "$PATH_PREFIX" \
	    "$USER_PERSISTENT_PATH"
	EOF

	launcher_write_script_prefix_prepare "$file"

	cat >> "$file" <<- 'EOF'
	prefix_build

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix cleanup
# USAGE: launcher_write_script_prefix_cleanup $file
# CALLED BY: launcher_write_build
launcher_write_script_prefix_cleanup() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Clean up user prefix
	persistent_update_from_prefix
	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}
