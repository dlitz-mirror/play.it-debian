# print a list of directories that should be saved in persistent paths
# USAGE: persistent_list_directories
# RETURNS: a list of paths to directories, one per line
#          glob patterns can be included
persistent_list_directories() {
	if [ -n "$USER_PERSISTENT_DIRECTORIES" ]; then
		printf '%s' "$USER_PERSISTENT_DIRECTORIES" | \
			grep --invert-match --regexp='^$'
	fi

	# If USER_PERSISTENT_DIRECTORIES is not set, try to fall back on legacy variables
	set +o noglob
	if [ -n "$CONFIG_DIRS" ]; then
		for directory in $CONFIG_DIRS; do
			printf '%s\n' "$directory"
		done
	fi
	if [ -n "$DATA_DIRS" ]; then
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
	if [ -n "$USER_PERSISTENT_FILES" ]; then
		printf '%s' "$USER_PERSISTENT_FILES" | \
			grep --invert-match --regexp='^$'
	fi

	# If USER_PERSISTENT_FILES is not set, try to fall back on legacy variables
	set +o noglob
	if [ -n "$CONFIG_FILES" ]; then
		for file in $CONFIG_FILES; do
			printf '%s\n' "$file"
		done
	fi
	if [ -n "$DATA_FILES" ]; then
		for file in $DATA_FILES; do
			printf '%s\n' "$file"
		done
	fi
	set -o noglob
}

# print list of variables setting persistent paths
# USAGE: launcher_print_persistent_paths
launcher_print_persistent_paths() {
	cat <<- 'EOF'
	# Set list of files and directories that should be saved in persistent paths

	USER_PERSISTENT_PATH="${XDG_DATA_HOME:=$HOME/.local/share}/games/${PREFIX_ID:=$GAME_ID}"
	EOF
	cat <<- EOF
	USER_PERSISTENT_DIRECTORIES='$(persistent_list_directories)'
	USER_PERSISTENT_FILES='$(persistent_list_files)'
	EOF
}
