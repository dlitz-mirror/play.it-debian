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

# print functions used to display localized messages
# USAGE: launcher_prefix_functions_localized_messages
launcher_prefix_functions_localized_messages() {
	cat <<- 'EOF'
	# select strings matching the current locale
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: localize $string[…]
	localize() {
	    local lang
	    local string
	    local match
	    for lang in "${LANG%%_*}" 'en'; do
	        for string in "$@"; do
	            if [ "${string%%:*}" = "$lang" ]; then
	                echo "${string#*:}"
	                match=1
	            fi
	        done
	        if [ "$match" ]; then
	            break
	        fi
	    done
	}

	# print a localized message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_message $string[…]
	display_message() {
	    local string
	    localize "$@" | while read -r string; do
	        printf "$string\n"
	    done 1>&2
	}

	# print a localized warning message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_warning $string[…]
	display_warning() {
	    display_message \
	        'en:\033[1;33mWarning:\033[0m' \
	        'fr:\033[1;33mAvertissement :\033[0m'
	    display_message "$@"
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
	    local reply
	    # clean up the prefix if a lock file is still present from a previous run
	    if [ -e "$PREFIX_LOCK" ]; then
	        display_warning \
	            "en:The game prefix ('$PATH_PREFIX') was not properly cleaned up (possibly from a previous game crash)." \
	            "fr:Le répertoire de jeu ('$PATH_PREFIX') n'a pas été nettoyé correctement (possiblement à cause d'un précédent plantage du jeu)."
	        while true; do
	            display_message \
	                "en:Clean up the game prefix? [(Y)es/(n)o/(q)uit]" \
	                "fr:Nettoyer le répertoire de jeu ? [(O)ui/(n)on/(q)uitter]"
	            read reply || :
	            reply="$(echo "$reply" | tr '[:upper:]' '[:lower:]')"
	            if [ -z "$reply" ] || [ "$reply" = "$(localize 'en:y' 'fr:o')" ]; then
	                prefix_cleanup
	                break
	            elif [ "$reply" = "$(localize 'en:n' 'fr:n')" ]; then
	                break
	            elif [ "$reply" = "$(localize 'en:q' 'fr:q')" ]; then
	                exit 1
	            fi
	            display_warning \
	                "en:Invalid answer: '$reply'." \
	                "fr:Réponse invalide : '$reply'."
	        done
	    fi
	    prefix_generate_links_farm
	    persistent_populate_prefix
	    persistent_init_directories
	    persistent_init_files
	    touch "$PREFIX_LOCK"
	}
	EOF
}

# print function cleaning up and synchronizing back user prefix
# USAGE: launcher_prefix_function_cleanup
launcher_prefix_function_cleanup() {
	cat <<- 'EOF'
	# clean up and synchronize back user prefix
	# USAGE: prefix_cleanup
	prefix_cleanup() {
	    persistent_update_from_prefix
	    rm --force "$PREFIX_LOCK"
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

		# Set localization and error reporting functions

		EOF
		launcher_prefix_functions_localized_messages
		cat <<- 'EOF'

		# Set userdir- and prefix-related functions

		EOF
		prefix_function_prefix_path
		launcher_prefix_functions_persistent
		prefix_generate_links_farm
		launcher_prefix_function_build
		launcher_prefix_function_cleanup
	} >> "$file"
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix prepare hook
# USAGE: launcher_write_script_prefix_prepare $file
launcher_write_script_prefix_prepare() {
	local file
	file="$1"

	if [ "$PREFIX_PREPARE" ]; then
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
	PREFIX_LOCK="$PATH_PREFIX/.$GAME_ID.lock"
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

	prefix_cleanup

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}
