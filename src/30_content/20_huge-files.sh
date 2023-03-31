# List huge files for the given package
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
