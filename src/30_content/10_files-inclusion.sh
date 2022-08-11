# Fetch files from the archive, and include them into the package skeleton.
# A list of default content identifiers is used.
# USAGE: content_inclusion_default
content_inclusion_default() {
	local packages_list package package_suffix index
	packages_list=$(packages_get_list)
	for package in $packages_list; do
		package_suffix=${package#PKG_}
		content_inclusion "GAME_${package_suffix}" "$package" "$PATH_GAME"
		content_inclusion "DOC_${package_suffix}" "$package" "$PATH_DOC"
		for index in $(seq 0 9); do
			content_inclusion "GAME${index}_${package_suffix}" "$package" "$PATH_GAME"
			content_inclusion "DOC${index}_${package_suffix}" "$package" "$PATH_DOC"
		done
	done
}

# Fetch files from the archive, and include them into the package skeleton.
# USAGE: content_inclusion $content_id $package $target_path
content_inclusion() {
	local content_id package target_path
	content_id="$1"
	package="$2"
	target_path="$3"

	# Return early if the content source path does not exist.
	local content_path
	content_path=$(content_path "$content_id")
	content_path_full="${PLAYIT_WORKDIR}/gamedata/${content_path}"
	if [ ! -e "$content_path_full" ]; then
		return 0
	fi

	# Set path to destination,
	# ensuring it is an absolute path.
	local package_path destination_path
	package_path=$(package_get_path "$package")
	destination_path=$(realpath --canonicalize-missing "${package_path}${target_path}")

	# Proceed with the actual files inclusion
	(
		cd "$content_path_full"
		while read -r file_pattern; do
			if [ -z "$file_pattern" ]; then
				continue
			fi
			if [ -e "$file_pattern" ]; then
				content_inclusion_include_file "$file_pattern" "$destination_path"
			else
				content_inclusion_include_pattern "$file_pattern" "$destination_path"
			fi
		done <<- EOF
		$(content_files "$content_id")
		EOF
	)
}

# Fetch a given file or directory from the archive,
# identified by an explicit path.
# Non existing files are skipped silently.
# USAGE: content_inclusion_include_file $file_path $destination_path
content_inclusion_include_file() {
	local file_path destination_path
	file_path="$1"
	destination_path="$2"

	# Skip silently files that are not found
	if [ ! -e "$file_path" ]; then
		return 0
	fi

	mkdir --parents "$destination_path"
	cp \
		--force \
		--link \
		--recursive \
		--no-dereference \
		--parents \
		--preserve=links \
		"$file_path" "$destination_path"
	rm --force --recursive "$file_path"
}

# Fetch several files or directories from the archive,
# identified by a pattern.
# USAGE: content_inclusion_include_pattern $file_pattern $destination_path
content_inclusion_include_pattern() {
	local file_pattern destination_path
	file_pattern="$1"
	destination_path="$2"

	local file_path
	while read -r file_path; do
		content_inclusion_include_file "$file_path" "$destination_path"
	done <<- EOF
	$(find . -path "./${file_pattern#./}")
	EOF
}
