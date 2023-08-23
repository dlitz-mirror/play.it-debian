# Set path for persistent storage of user data, and populate the game prefix from the persistent storage
# USAGE: persistent_storage_initialization
persistent_storage_initialization() {
	{
		cat <<- 'EOF'
		# Set path for persistent storage of user data
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
		USER_PERSISTENT_PATH=$(persistent_user_path)
		mkdir --parents "$USER_PERSISTENT_PATH"

		# Populate the prefix from persistent files
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

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# Set the common actions required for directories and files diversion to persistent storage
# This is required for the diversions using one of the following variables:
# - USER_PERSISTENT_DIRECTORIES
# - USER_PERSISTENT_FILES
# USAGE: persistent_storage_common
persistent_storage_common() {
	local persistent_list_directories persistent_list_files
	persistent_list_directories=$(persistent_list_directories)
	persistent_list_files=$(persistent_list_files)

	# Return early if the current game script does not use paths diversion
	if \
		[ -z "$persistent_list_directories" ] && \
		[ -z "$persistent_list_files" ]
	then
		return 0
	fi

	{
		cat <<- 'EOF'
		# Expand a path pattern into a list of existing paths.
		# If the pattern can not be expanded, it is printed as-is instead.
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
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# Set the action used to divert a given path to persistent storage
# This is required for the diversions using one of the following variables:
# - USER_PERSISTENT_DIRECTORIES
# - WINE_PERSISTENT_DIRECTORIES
# USAGE: persistent_path_diversion
persistent_path_diversion() {
	local persistent_list_directories wine_persistent_directories
	persistent_list_directories=$(persistent_list_directories)
	wine_persistent_directories=$(wine_persistent_directories)

	# Return early if the current game script does not use paths diversion
	if \
		[ -z "$persistent_list_directories" ] && \
		[ -z "$wine_persistent_directories" ]
	then
		return 0
	fi

	{
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
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# print a list of directories that should be saved in persistent paths
# USAGE: persistent_list_directories
# RETURNS: a list of paths to directories, one per line
#          glob patterns can be included
persistent_list_directories() {
	if [ -n "${USER_PERSISTENT_DIRECTORIES:-}" ]; then
		printf '%s' "$USER_PERSISTENT_DIRECTORIES" | \
			grep --invert-match --regexp='^$'
	fi

	# If USER_PERSISTENT_DIRECTORIES is not set, try to fall back on legacy variables
	set +o noglob
	if [ -n "${CONFIG_DIRS:-}" ]; then
		for directory in $CONFIG_DIRS; do
			printf '%s\n' "$directory"
		done
	fi
	if [ -n "${DATA_DIRS:-}" ]; then
		for directory in $DATA_DIRS; do
			printf '%s\n' "$directory"
		done
	fi
	set -o noglob
}

# Update directories diversions to persistent storage
# USAGE: persistent_storage_update_directories
persistent_storage_update_directories() {
	local persistent_list_directories
	persistent_list_directories=$(persistent_list_directories)

	# Return early if the current game script does not use directories diversion
	if [ -z "$persistent_list_directories" ]; then
		return 0
	fi

	{
		cat <<- EOF
		# Update directories diversions to persistent storage
		USER_PERSISTENT_DIRECTORIES='${persistent_list_directories}'
		EOF
		cat <<- 'EOF'
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

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# print a list of files that should be saved in persistent paths
# USAGE: persistent_list_files
# RETURNS: a list of paths to files, one per line
#          glob patterns can be included
persistent_list_files() {
	if [ -n "${USER_PERSISTENT_FILES:-}" ]; then
		printf '%s' "$USER_PERSISTENT_FILES" | \
			grep --invert-match --regexp='^$'
	fi

	# If USER_PERSISTENT_FILES is not set, try to fall back on legacy variables
	set +o noglob
	if [ -n "${CONFIG_FILES:-}" ]; then
		for file in $CONFIG_FILES; do
			printf '%s\n' "$file"
		done
	fi
	if [ -n "${DATA_FILES:-}" ]; then
		for file in $DATA_FILES; do
			printf '%s\n' "$file"
		done
	fi
	set -o noglob
}

# Update files diversions to persistent storage
# USAGE: persistent_storage_update_files
persistent_storage_update_files() {
	local persistent_list_files
	persistent_list_files=$(persistent_list_files)

	# Return early if the current game script does not use files diversion
	if [ -z "$persistent_list_files" ]; then
		return 0
	fi

	{
		cat <<- EOF
		# Update files diversions to persistent storage
		USER_PERSISTENT_FILES='${persistent_list_files}'
		EOF
		cat <<- 'EOF'
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

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

# Update persistent storage with files from the current prefix
# USAGE: persistent_storage_update_files_from_prefix
persistent_storage_update_files_from_prefix() {
	local persistent_list_files
	persistent_list_files=$(persistent_list_files)

	# Return early if the current game script does not use files diversion
	if [ -z "$persistent_list_files" ]; then
		return 0
	fi

	{
		cat <<- 'EOF'
		# Update persistent storage with files from the current prefix
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

		EOF
	} | sed --regexp-extended 's/( ){4}/\t/g'
}

