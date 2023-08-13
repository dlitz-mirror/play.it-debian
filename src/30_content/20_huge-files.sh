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

# List the chunks generated from a given file
# USAGE: huge_file_chunks_list $file_path
# RETURN: a list of files,
#         one per line
huge_file_chunks_list() {
	local file_path
	file_path="$1"

	local content_path
	content_path=$(content_path_default)
	(
		cd "${PLAYIT_WORKDIR}/gamedata/${content_path}"
		find . -path "./${file_path}.?" | \
			sort | \
			sed 's#^\./##'
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

# Split huge files in chunks, and include them in dedicated packages
# USAGE: content_inclusion_chunks $package
content_inclusion_chunks() {
	local package
	package="$1"

	local huge_files
	huge_files=$(huge_files_list "$package")

	# Return early if no list is set for the given package
	if [ -z "$huge_files" ]; then
		return 0
	fi

	local huge_file chunks_list chunk_path chunks_counter
	chunks_counter=1
	while read -r huge_file; do
		# Split the current huge files into 9GB chunks
		huge_file_split "$huge_file"

		# Include each chunk into a dedicated new package
		chunks_list=$(huge_file_chunks_list "$huge_file")
		while read -r chunk_path; do
			content_inclusion_chunk_single "$package" "$chunk_path" "$chunks_counter"
			chunks_counter=$((chunks_counter + 1))
		done <<- EOL1
		$(printf '%s' "$chunks_list")
		EOL1

		# Set the postinst commands used to rebuild the file from its chunks
		## The file deletion is done when removing the chunks packages (see content_inclusion_chunk_single),
		## to avoid deleting it when reinstalling the main package without rebuilding it afterwards
		## because the chunks have been deleted already.
		local postinst_commands extra_postinst_commands
		postinst_commands=$(get_value "${package}_POSTINST_RUN")
		extra_postinst_commands=$(huge_file_concatenate "$huge_file")
		export "${package}_POSTINST_RUN"="$postinst_commands
		$extra_postinst_commands"
	done <<- EOL2
	$(printf '%s' "$huge_files")
	EOL2
}

# Include a single chunk into a new dedicated package
# USAGE: content_inclusion_chunk_single $package $chunk_path $chunks_counter
content_inclusion_chunk_single() {
	local package chunk_path chunks_counter
	package="$1"
	chunk_path="$2"
	chunks_counter="$3"

	# Compute the new package identifier and its content identifier
	local package_identifier package_suffix content_id
	package_identifier="${package}_CHUNK${chunks_counter}"
	package_suffix="${package_identifier#PKG_}"
	content_id="GAME_${package_suffix}"

	# Add the new package to the list of packages to build
	local packages_list
	packages_list=$(packages_get_list)
	export PACKAGES_LIST="$package_identifier $packages_list"

	# Set the new package properties
	local package_id package_description prerm_commands
	package_id=$(package_id "$package")
	package_description=$(package_description "$package")
	prerm_commands=$(huge_file_delete "$huge_file")
	export "${package_identifier}_ID"="${package_id}-chunk${chunks_counter}"
	export "${package_identifier}_DESCRIPTION"="${package_description} - chunk ${chunks_counter}"
	export "${package_identifier}_PRERM_RUN"="$prerm_commands"

	# Add the new package to the list of dependencies of its parent
	dependencies_add_generic "$package" "${package_id}-chunk${chunks_counter}"

	# Include the chunk into the new package
	local path_game
	path_game=$(path_game_data)
	export "CONTENT_${content_id}_FILES"="$chunk_path"
	content_inclusion "$content_id" "$package_identifier" "$path_game"
}
