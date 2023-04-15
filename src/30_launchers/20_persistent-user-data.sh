# print a list of directories that should be saved in persistent paths
# USAGE: persistent_list_directories
# RETURNS: a list of paths to directories, one per line
#          glob patterns can be included
persistent_list_directories() {
	if ! variable_is_empty 'USER_PERSISTENT_DIRECTORIES'; then
		printf '%s' "$USER_PERSISTENT_DIRECTORIES" | \
			grep --invert-match --regexp='^$'
	fi

	# If USER_PERSISTENT_DIRECTORIES is not set, try to fall back on legacy variables
	set +o noglob
	if ! variable_is_empty 'CONFIG_DIRS'; then
		for directory in $CONFIG_DIRS; do
			printf '%s\n' "$directory"
		done
	fi
	if ! variable_is_empty 'DATA_DIRS'; then
		for directory in $DATA_DIRS; do
			printf '%s\n' "$directory"
		done
	fi
	set -o noglob
}

# print a list of files that should be saved in persistent paths
# USAGE: persistent_list_files
# RETURNS: a list of paths to files, one per line
#          glob patterns can be included
persistent_list_files() {
	if ! variable_is_empty 'USER_PERSISTENT_FILES'; then
		printf '%s' "$USER_PERSISTENT_FILES" | \
			grep --invert-match --regexp='^$'
	fi

	# If USER_PERSISTENT_FILES is not set, try to fall back on legacy variables
	set +o noglob
	if ! variable_is_empty 'CONFIG_FILES'; then
		for file in $CONFIG_FILES; do
			printf '%s\n' "$file"
		done
	fi
	if ! variable_is_empty 'DATA_FILES'; then
		for file in $DATA_FILES; do
			printf '%s\n' "$file"
		done
	fi
	set -o noglob
}

# Print function computing the path for persistent storage of user data
# USAGE: persistent_function_user_path
persistent_function_user_path() {
	cat <<- 'EOF'
	# Print path to directory used for persistent storage of user data
	persistent_user_path() {
	    # The path can be explicitely set using an environment variable
	    if [ -n "$PLAYIT_PERSISTENT_USER_PATH" ]; then
	        printf '%s' "$PLAYIT_PERSISTENT_USER_PATH"
	        return 0
	    fi
	    # Compute the default path if none has been explicitly set
	    printf '%s/games/%s' \
	        "${XDG_DATA_HOME:=$HOME/.local/share}" \
	        "$GAME_ID"
	}
	EOF
}

# print list of variables setting persistent paths
# USAGE: launcher_print_persistent_paths
launcher_print_persistent_paths() {
	persistent_function_user_path
	cat <<- 'EOF'
	USER_PERSISTENT_PATH=$(persistent_user_path)
	EOF

	local persistent_list_directories persistent_list_files
	persistent_list_directories=$(persistent_list_directories)
	persistent_list_files=$(persistent_list_files)
	cat <<- EOF
	# Set list of files and directories that should be saved in persistent paths
	USER_PERSISTENT_DIRECTORIES='${persistent_list_directories}'
	USER_PERSISTENT_FILES='${persistent_list_files}'
	EOF
}

# print function expanding a pattern into existing paths
# USAGE: launcher_prefix_function_expand_path_pattern
launcher_prefix_function_expand_path_pattern() {
	cat <<- 'EOF'
	# Expand path pattern
	expand_path_pattern() {
	    local pattern
	    pattern="$1"

	    # Silently skip empty patterns
	    if [ -z "$pattern" ]; then
	      return 0
	    fi

	    local expanded_paths
	    expanded_paths=$(find . -path "./${pattern#./}")
	    if [ -n "$expanded_paths" ]; then
	        printf '%s\n' "$expanded_paths"
	    else
	        printf '%s\n' "$pattern"
	    fi
	}
	EOF
}

# print function populating the prefix from persistent files
# USAGE: launcher_prefix_function_persistent_populate_prefix
launcher_prefix_function_persistent_populate_prefix() {
	cat <<- 'EOF'
	# Populate the prefix from persistent files
	persistent_populate_prefix() {
	    (
	        cd "$USER_PERSISTENT_PATH"
	        find -L . -type f ! -path './wine/*' | while read -r file; do
	            persistent_file="${USER_PERSISTENT_PATH}/${file}"
	            prefix_file="${PATH_PREFIX}/${file}"
	            if \
	                [ ! -e "$prefix_file" ] || \
	                [ "$(realpath "$prefix_file")" != "$(realpath "$persistent_file")" ]
	            then
	                mkdir --parents "$(dirname "$prefix_file")"
	                ln --symbolic --force --no-target-directory \
	                    "$persistent_file" \
	                    "$prefix_file"
	            fi
	        done
	    )
	}
	EOF
}

# Print the function used to divert a given path to persistent storage
# USAGE: persistent_path_diversion
persistent_path_diversion() {
	cat <<- 'EOF'
	# Replace a given directory in a prefix by a link to another directory in persistent storage
	# USAGE: persistent_path_diversion $path_source $path_destination $directory
	persistent_path_diversion() {
	    local path_source path_destination directory
	    path_source="$1"
	    path_destination="$2"
	    directory="$3"

	    # If the target directory does not already exist in persistent storage,
	    # copy it from the prefix (if existing) or create a new empty one.
	    if [ ! -e "${path_destination}/${directory}" ]; then
	        if [ -e "${path_source}/${directory}" ]; then
	            (
	                cd "$path_source"
	                cp --dereference --parents --recursive \
	                    "$directory" \
	                    "$path_destination"
				)
	        else
	            mkdir --parents "${path_destination}/${directory}"
	        fi
	    fi

	    # Replace the directory in the prefix by a link to the one in persistent storage.
	    if [ ! -h "${path_source}/${directory}" ]; then
	        local directory_parent
	        directory_parent=$(dirname "${path_source}/${directory}")
	        rm --recursive --force "${path_source:?}/${directory}"
	        mkdir --parents "$directory_parent"
	        ln --symbolic "${path_destination}/${directory}" "${path_source}/${directory}"
	    fi
	}

	EOF
}

# print function initializing persistent directories
# USAGE: launcher_prefix_function_persistent_init_directories
launcher_prefix_function_persistent_init_directories() {
	cat <<- 'EOF'
	# Initialize persistent directories
	persistent_init_directories() {
	    # Return early if there is nothing to do
	    if [ -z "$USER_PERSISTENT_DIRECTORIES" ]; then
	        return 0
	    fi
	    (
	        cd "$PATH_PREFIX"
	        while read -r directory_pattern; do
	            # Skip empty patterns
	            if [ -z "$directory_pattern" ]; then
	                continue
	            fi
	            while read -r directory; do
	                persistent_path_diversion "$PATH_PREFIX" "$USER_PERSISTENT_PATH" "$directory"
	            done <<- EOL
	            $(expand_path_pattern "$directory_pattern")
	            EOL
	        done <<- EOL
	        $(printf '%s' "$USER_PERSISTENT_DIRECTORIES")
	        EOL
	    )
	}
	EOF
}

# print function initializing persistent files
# USAGE: launcher_prefix_function_persistent_init_files
launcher_prefix_function_persistent_init_files() {
	cat <<- 'EOF'
	# Initialize persistent files
	persistent_init_files() {
	    # Return early if there is nothing to do
	    if [ -z "$USER_PERSISTENT_FILES" ]; then
	        return 0
	    fi
	    (
	        cd "$PATH_PREFIX"
	        while read -r file_pattern; do
	            # Skip empty patterns
	            if [ -z "$file_pattern" ]; then
	                continue
	            fi
	            while read -r file; do
	                if [ ! -e "${USER_PERSISTENT_PATH}/${file}" ]; then
	                    # If the target file does not already exist in persistent storage,
	                    # copy it from the prefix (if existing).
	                    if [ -e "$file" ]; then
	                        cp --dereference --parents \
	                            "$file" \
	                            "${USER_PERSISTENT_PATH}"
	                    fi
	                fi
	                # Replace the file in the prefix by a link to the one in persistent storage,
	                # if such a file already exists in persistent storage.
	                if [ -e "${USER_PERSISTENT_PATH}/${file}" ]; then
	                    file_parent=$(dirname "$file")
	                    rm --force "$file"
	                    mkdir --parents "$file_parent"
	                    ln --symbolic "${USER_PERSISTENT_PATH}/${file}" "$file"
	                fi
	            done <<- EOL
	            $(expand_path_pattern "$file_pattern")
	            EOL
	        done <<- EOL
	        $(printf '%s' "$USER_PERSISTENT_FILES")
	        EOL
	    )
	}
	EOF
}

# print function updating persistent paths from prefix content
# USAGE: launcher_prefix_function_persistent_update_from_prefix
launcher_prefix_function_persistent_update_from_prefix() {
	cat <<- 'EOF'
	# Update persistent paths from prefix content
	persistent_update_from_prefix() {
	    (
	        cd "$PATH_PREFIX"
	        while read -r path_pattern; do
	            # Skip empty patterns
	            if [ -z "$path_pattern" ]; then
	                continue
	            fi
	            while read -r path; do
	                if [ -f "$path" ] && [ ! -h "$path" ]; then
	                    cp --parents --remove-destination "$path" "$USER_PERSISTENT_PATH"
	                    rm --force "$path"
	                    ln --symbolic "${USER_PERSISTENT_PATH}/${path}" "$path"
	                fi
	            done <<- EOL
	            $(expand_path_pattern "$path_pattern")
	            EOL
	        done <<- EOL
	        $(printf '%s' "$USER_PERSISTENT_FILES")
	        EOL
	    )
	}
	EOF
}

# print functions handling persistent storage
# USAGE: launcher_prefix_functions_persistent
launcher_prefix_functions_persistent() {
	persistent_path_diversion
	launcher_prefix_function_expand_path_pattern
	launcher_prefix_function_persistent_populate_prefix
	launcher_prefix_function_persistent_init_directories
	launcher_prefix_function_persistent_init_files
	launcher_prefix_function_persistent_update_from_prefix
}
