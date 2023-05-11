# Gentoo - Print the package names providing the GStreamer plugins to decode the formats required by the given package
# USAGE: gentoo_dependencies_gstreamer_all_formats $package
# RETURN: a list of Gentoo package names,
#         one per line
gentoo_dependencies_gstreamer_all_formats() {
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
			command_dependencies_for_single_format='gentoo_dependencies_gstreamer_single_format_32bit'
		;;
		(*)
			command_dependencies_for_single_format='gentoo_dependencies_gstreamer_single_format'
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

# Gentoo - Print the package names providing the required GStreamer plugins to decode the given format
# USAGE: gentoo_dependency_providing_gstreamer_plugin $media_format
# RETURN: a list of Gentoo package names,
#         one per line
gentoo_dependencies_gstreamer_single_format() {
	local media_format
	media_format="$1"

	local package_names
	case "$media_format" in
		('avidemux')
			package_names='
			media-libs/gst-plugins-good'
		;;
		('decodebin')
			package_names='
			media-libs/gst-plugins-base'
		;;
		('deinterlace')
			package_names='
			media-libs/gst-plugins-good'
		;;
		('application/x-id3')
			package_names='
			media-libs/gst-plugins-good'
		;;
		('audio/mpeg, mpegversion=(int)1, layer=(int)3')
			package_names='
			media-libs/gst-plugins-good'
		;;
		('audio/x-wma, wmaversion=(int)1')
			package_names='
			media-plugins/gst-plugins-libav'
		;;
		('video/mpeg, systemstream=(boolean)true, mpegversion=(int)1')
			package_names='
			media-libs/gst-plugins-ugly
			media-libs/gst-plugins-bad'
		;;
		('video/quicktime, variant=(string)iso')
			package_names='
			media-libs/gst-plugins-good
			media-plugins/gst-plugins-libav'
		;;
		('video/x-ms-asf')
			package_names='
			media-libs/gst-plugins-ugly
			media-plugins/gst-plugins-libav'
		;;
		('video/x-msvideo')
			package_names='
			media-libs/gst-plugins-good
			media-plugins/gst-plugins-libav'
		;;
		('video/x-wmv, wmvversion=(int)1')
			package_names='
			media-plugins/gst-plugins-libav'
		;;
		(*)
			dependencies_unknown_gstreamer_media_formats_add "$media_format"
			return 0
		;;
	esac

	printf '%s' "$package_names"
}

# Gentoo - Print the package names providing the required GStreamer plugins to decode the given format (32-bit)
# USAGE: gentoo_dependency_providing_gstreamer_plugin_32bit $media_format
# RETURN: a list of Gentoo package names,
#         one per line
gentoo_dependencies_gstreamer_single_format_32bit() {
	local media_format
	media_format="$1"

	local package_names
	case "$media_format" in
		('avidemux')
			package_names='
			media-libs/gst-plugins-good[abi_x86_32]'
		;;
		('decodebin')
			package_names='
			media-libs/gst-plugins-base[abi_x86_32]'
		;;
		('deinterlace')
			package_names='
			media-libs/gst-plugins-good[abi_x86_32]'
		;;
		('application/x-id3')
			package_names='
			media-libs/gst-plugins-good[abi_x86_32]'
		;;
		('audio/mpeg, mpegversion=(int)1, layer=(int)3')
			package_names='
			media-libs/gst-plugins-good[abi_x86_32]'
		;;
		('audio/x-wma, wmaversion=(int)1')
			package_names='
			media-plugins/gst-plugins-libav[abi_x86_32]'
		;;
		('video/mpeg, systemstream=(boolean)true, mpegversion=(int)1')
			package_names='
			media-libs/gst-plugins-ugly[abi_x86_32]
			media-libs/gst-plugins-bad[abi_x86_32]'
		;;
		('video/quicktime, variant=(string)iso')
			package_names='
			media-libs/gst-plugins-good[abi_x86_32]
			media-plugins/gst-plugins-libav[abi_x86_32]'
		;;
		('video/x-ms-asf')
			package_names='
			media-libs/gst-plugins-ugly[abi_x86_32]
			media-plugins/gst-plugins-libav[abi_x86_32]'
		;;
		('video/x-msvideo')
			package_names='
			media-libs/gst-plugins-good[abi_x86_32]
			media-plugins/gst-plugins-libav[abi_x86_32]'
		;;
		('video/x-wmv, wmvversion=(int)1')
			package_names='
			media-plugins/gst-plugins-libav[abi_x86_32]'
		;;
		(*)
			dependencies_unknown_gstreamer_media_formats_add "$media_format"
			return 0
		;;
	esac

	printf '%s' "$package_names"
}
