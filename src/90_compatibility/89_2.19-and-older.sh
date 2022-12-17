# Keep compatibility with 2.19 and older

dosbox_prerun_legacy() {
	local application
	application="$1"

	if variable_is_empty "${application}_PRERUN"; then
		return 0
	fi

	local dosbox_prerun
	dosbox_prerun=$(get_value "${application}_PRERUN")
	printf '%s' "$dosbox_prerun"
}

dosbox_postrun_legacy() {
	local application
	application="$1"

	if variable_is_empty "${application}_POSTRUN"; then
		return 0
	fi

	local dosbox_postrun
	dosbox_postrun=$(get_value "${application}_POSTRUN")
	printf '%s' "$dosbox_postrun"
}
