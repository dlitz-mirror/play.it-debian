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
