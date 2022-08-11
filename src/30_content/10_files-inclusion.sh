# Fetch game data from the files extracted from archives,
# and put them in the directories used to prepare the packages.
# USAGE: prepare_package_layout [$pkg…]
prepare_package_layout() {
	# If prepare_package_layout has been called with no argument,
	# it is assumed that all packages should be handled.
	if [ $# -eq 0 ]; then
		local packages_list
		packages_list=$(packages_get_list)
		prepare_package_layout $packages_list
		return 0
	fi

	debug_entering_function 'prepare_package_layout'

	# Changes to PKG value, expected by organize_data,
	# should not leak outside of the current prepare_package_layout call.
	local PKG

	local package
	for package in "$@"; do
		PKG="$package"
		organize_data "GAME_${package#PKG_}" "$PATH_GAME"
		organize_data "DOC_${package#PKG_}"  "$PATH_DOC"
		for i in $(seq 0 9); do
			organize_data "GAME${i}_${package#PKG_}" "$PATH_GAME"
			organize_data "DOC${i}_${package#PKG_}"  "$PATH_DOC"
		done
	done

	debug_leaving_function 'prepare_package_layout'
}

# Fetch files from the archive, and include them into the package skeleton.
# USAGE: content_inclusion $content_id $target_path
content_inclusion() {
	local content_id target_path
	content_id="$1"
	target_path="$2"

	# Return early if the content source path does not exist.
	local content_path
	content_path=$(content_path "$content_id")
	content_path_full="${PLAYIT_WORKDIR}/gamedata/${content_path}"
	if [ ! -e "$content_path_full" ]; then
		return 0
	fi

	# Set path to destination,
	# ensuring it is an absolute path.
	local package package_path destination_path
	package=$(package_get_current)
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
