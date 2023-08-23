# Print the list of GStreamer decoders required by a given package
# USAGE: dependencies_list_gstreamer_decoders $package
# RETURNS: a list of GStreamer decoders,
#          one per line
dependencies_list_gstreamer_decoders() {
	local package
	package="$1"

	local gstreamer_decoders
	gstreamer_decoders=$(context_value "${package}_DEPENDENCIES_GSTREAMER_PLUGINS")

	# Fall back on a default list based on the game engine
	if [ -z "$gstreamer_decoders" ]; then
		## Unreal Engine 4
		local unrealengine4_name
		unrealengine4_name=$(unrealengine4_name)
		if [ -n "$unrealengine4_name" ]; then
			gstreamer_decoders=$(unrealengine4_dependencies_list_gstreamer_decoders_default "$package")
		fi
	fi

	# Return early if the current package does not require any GStreamer decoder
	if [ -z "$gstreamer_decoders" ]; then
		return 0
	fi

	# Always return a list with no duplicate entry,
	# excluding empty lines.
	# Ignore grep error return if there is nothing to print.
	printf '%s' "$gstreamer_decoders" | \
		sort --unique | \
		grep --invert-match --regexp='^$' || true
}

# Print the path to a temporary files used for unknown GStreamer media formats listing
# USAGE: dependencies_unknown_gstreamer_media_formats_file
dependencies_unknown_gstreamer_media_formats_file() {
	printf '%s/unknown_gstreamer_media_formats_list' "$PLAYIT_WORKDIR"
}

# Print a list of unknown GStreamer media formats
# USAGE: dependencies_unknown_gstreamer_media_formats_list
dependencies_unknown_gstreamer_media_formats_list() {
	local unknown_formats_list
	unknown_formats_list=$(dependencies_unknown_gstreamer_media_formats_file)

	# Return early if there is no unknown library
	if [ ! -e "$unknown_formats_list" ]; then
		return 0
	fi

	# Display the list of unknown formats,
	# skipping duplicates and empty entries.
	sort --unique "$unknown_formats_list" | \
		grep --invert-match --regexp='^$'
}

# Clear the list of unknown GStreamer media formats
# USAGE: dependencies_unknown_gstreamer_media_formats_clear
dependencies_unknown_gstreamer_media_formats_clear() {
	local unknown_formats_list
	unknown_formats_list=$(dependencies_unknown_gstreamer_media_formats_file)

	rm --force "$unknown_formats_list"
}

# Add a GStreamer media format to the list of unknown ones
# USAGE: dependencies_unknown_gstreamer_media_formats_add $unknown_format
dependencies_unknown_gstreamer_media_formats_add() {
	local unknown_format unknown_formats_list
	unknown_format="$1"
	unknown_formats_list=$(dependencies_unknown_gstreamer_media_formats_file)

	# Do nothing if this format is already included in the list
	if \
		[ -e "$unknown_formats_list" ] \
		&& grep --quiet --fixed-strings --word-regexp "$unknown_format" "$unknown_formats_list"
	then
		return 0
	fi

	printf '%s\n' "$unknown_format" >> "$unknown_formats_list"
}
