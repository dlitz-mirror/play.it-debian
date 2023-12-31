# Print function computing the path to the game prefix
# USAGE: prefix_function_prefix_path
prefix_function_prefix_path() {
	{
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
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# Populate prefix with symbolic links to all game files
# USAGE: prefix_generate_links_farm
prefix_generate_links_farm() {
	{
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
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# Print the functions used to generate a symlinks prefix
# USAGE: launcher_prefix_symlinks_functions
launcher_prefix_symlinks_functions() {
		cat <<- 'EOF'
		# Set userdir- and prefix-related functions
		EOF
		prefix_function_prefix_path
		prefix_generate_links_farm
}

# Print the actions used to build a symlinks prefix
# USAGE: launcher_prefix_symlinks_build
launcher_prefix_symlinks_build() {
	cat  <<- 'EOF'
	# Build user prefix

	PATH_PREFIX=$(prefix_path)
	mkdir --parents "$PATH_PREFIX"
	prefix_generate_links_farm

	EOF
}

