# List huge files for the given package
# The paths should be relative to CONTENT_PATH_DEFAULT.
# USAGE: huge_files_list $package
# RETURN: a list of files,
#         one per line
huge_files_list() {
	local package
	package="$1"

	local huge_files
	huge_files=$(context_value "HUGE_FILES_${package#PKG_}")

	# Return early if no list is set for the given package
	if [ -z "$huge_files" ]; then
		return 0
	fi

	printf '%s' "$huge_files" | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Split the given file into 9GB chunks
# USAGE: huge_file_split $file_path
huge_file_split() {
	local file_path
	file_path="$1"

	information_huge_file_split "$file_path"

	local content_path
	content_path=$(content_path_default)
	(
		cd "${PLAYIT_WORKDIR}/gamedata/${content_path}"
		split --bytes=9G --numeric-suffixes=1 --suffix-length=1 \
			"$file_path" \
			"${file_path}."
		rm --force "$file_path"
	)
}

# Print the commands concatenating chunks into a single file
# USAGE: huge_file_concatenate $file_path
huge_file_concatenate() {
	local file_path
	file_path="$1"

	local path_game
	path_game=$(path_game_data)

	cat <<- EOF
	# Rebuild a huge file from its chunks
	huge_file='${path_game}/${file_path}'
	EOF
	cat <<- 'EOF'
	for huge_file_chunk in "${huge_file}."*; do
	    if [ -e "$huge_file_chunk" ]; then
	        case "${LANG%_*}" in
	            ('fr')
	                message='Reconstruction de %s à partir de ses parties…\n'
	            ;;
	            ('en'|*)
	                message='Rebuilding %s from its chunks…\n'
	            ;;
	        esac
	        printf "$message" "$huge_file"
	        cat "${huge_file}."* > "$huge_file"
	        rm "${huge_file}."*
	        break
	    fi
	done
	EOF
}

# Print the commands deleting a single file that has been built from its chunks
# USAGE: huge_file_delete $file_path
huge_file_delete() {
	local file_path
	file_path="$1"

	local path_game
	path_game=$(path_game_data)

	cat <<- EOF
	# Delete a huge file that has been built from its chunks
	huge_file='${path_game}/${file_path}'
	EOF
	cat <<- 'EOF'
	rm --force "$huge_file"
	EOF
}
