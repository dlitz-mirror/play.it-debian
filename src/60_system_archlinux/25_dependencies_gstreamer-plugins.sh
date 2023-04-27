# Arch Linux - Print the package names providing the GStreamer plugins to decode the formats required by the given package
# USAGE: archlinux_dependencies_gstreamer_all_formats $package
# RETURN: a list of Arch Linux package names,
#         one per line
archlinux_dependencies_gstreamer_all_formats() {
	local package
	package="$1"

	local required_media_formats
	required_media_formats=$(dependencies_list_gstreamer_media_formats "$package")
	# Return early if the current package does not require any GStreamer plugin
	if [ -z "$required_media_formats" ]; then
		return 0
	fi

	local package_architecture command_dependencies_for_single_format
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			command_dependencies_for_single_format='archlinux_dependencies_gstreamer_single_format_32bit'
		;;
		(*)
			command_dependencies_for_single_format='archlinux_dependencies_gstreamer_single_format'
		;;
	esac

	local media_format packages_list required_packages
	packages_list=''
	while read -r media_format; do
		required_packages=$("$command_dependencies_for_single_format" "$media_format")
		packages_list="$packages_list
		$required_packages"
	done <<- EOL
	$(printf "$required_media_formats")
	EOL

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Arch Linux - Print the package names providing the required GStreamer plugins to decode the given format
# USAGE: archlinux_dependency_providing_gstreamer_plugin $media_format
# RETURN: a list of Arch Linux package names,
#         one per line
archlinux_dependencies_gstreamer_single_format() {
	local media_format
	media_format="$1"

	local package_names
	case "$media_format" in
		('avidemux')
			package_names='
			gst-plugins-good'
		;;
		('decodebin')
			package_names='
			gst-plugins-base'
		;;
		('deinterlace')
			package_names='
			gst-plugins-good'
		;;
		('audio/x-wma, wmaversion=(int)1')
			package_names='
			gst-libav'
		;;
		('video/quicktime, variant=(string)iso')
			package_names='
			gst-plugins-good
			gst-libav'
		;;
		('video/x-ms-asf')
			package_names='
			gst-plugins-ugly
			x-ms-asf'
		;;
		('video/x-msvideo')
			package_names='
			gst-plugins-good
			gst-libav'
		;;
		('video/x-wmv, wmvversion=(int)1')
			package_names='
			gst-libav'
		;;
		(*)
			dependencies_unknown_gstreamer_media_formats_add "$media_format"
			return 0
		;;
	esac

	printf '%s' "$package_names"
}

# Arch Linux - Print the package names providing the required GStreamer plugins to decode the given format (32-bit)
# USAGE: archlinux_dependency_providing_gstreamer_plugin_32bit $media_format
# RETURN: a list of Arch Linux package names,
#         one per line
archlinux_dependencies_gstreamer_single_format_32bit() {
	local media_format
	media_format="$1"

	local package_names
	case "$media_format" in
		('avidemux')
			package_names='
			lib32-gst-plugins-good'
		;;
		('decodebin')
			package_names='
			lib32-gst-plugins-base'
		;;
		('deinterlace')
			package_names='
			lib32-gst-plugins-good'
		;;
		('audio/x-wma, wmaversion=(int)1')
			package_names='
			lib32-gst-libav'
		;;
		('video/quicktime, variant=(string)iso')
			package_names='
			lib32-gst-plugins-good
			lib32-gst-libav'
		;;
		('video/x-ms-asf')
			package_names='
			lib32-gst-plugins-ugly
			lib32-gst-libav'
		;;
		('video/x-msvideo')
			package_names='
			lib32-gst-plugins-good
			lib32-gst-libav'
		;;
		('video/x-wmv, wmvversion=(int)1')
			package_names='
			lib32-gst-libav'
		;;
		(*)
			dependencies_unknown_gstreamer_media_formats_add "$media_format"
			return 0
		;;
	esac

	printf '%s' "$package_names"
}
