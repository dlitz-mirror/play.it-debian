# Debian - Print the package names providing the GStreamer plugins to decode the formats required by the given package
# USAGE: debian_dependencies_gstreamer_all_formats $package
# RETURN: a list of Debian package names,
#         one per line
debian_dependencies_gstreamer_all_formats() {
	local package
	package="$1"

	local gstreamer_decoders
	gstreamer_decoders=$(dependencies_list_gstreamer_decoders "$package")
	# Return early if the current package does not require any GStreamer plugin
	if [ -z "$gstreamer_decoders" ]; then
		return 0
	fi

	local media_format packages_list required_packages
	packages_list=''
	while read -r media_format; do
		required_packages=$(debian_dependencies_gstreamer_single_format "$media_format")
		packages_list="$packages_list
		$required_packages"
	done <<- EOL
	$(printf "$gstreamer_decoders")
	EOL

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Debian - Print the package names providing the required GStreamer plugins to decode the given format
# USAGE: debian_dependency_providing_gstreamer_plugin $media_format
# RETURN: a list of Debian package names,
#         one per line
debian_dependencies_gstreamer_single_format() {
	local media_format
	media_format="$1"

	local package_names
	case "$media_format" in
		('avidemux')
			package_names='
			gstreamer1.0-plugins-good'
		;;
		('decodebin')
			package_names='
			gstreamer1.0-plugins-base'
		;;
		('deinterlace')
			package_names='
			gstreamer1.0-plugins-good'
		;;
		('application/x-id3')
			package_names='
			gstreamer1.0-plugins-good'
		;;
		('audio/mpeg, mpegversion=(int)1, layer=(int)3')
			package_names='
			gstreamer1.0-plugins-good'
		;;
		('audio/x-wma, wmaversion=(int)1')
			package_names='
			gstreamer1.0-libav'
		;;
		('video/mpeg, systemstream=(boolean)true, mpegversion=(int)1')
			package_names='
			gstreamer1.0-plugins-ugly
			gstreamer1.0-plugins-bad'
		;;
		('video/quicktime, variant=(string)iso')
			package_names='
			gstreamer1.0-plugins-good
			gstreamer1.0-libav'
		;;
		('video/x-ms-asf')
			package_names='
			gstreamer1.0-plugins-ugly
			gstreamer1.0-libav'
		;;
		('video/x-msvideo')
			package_names='
			gstreamer1.0-plugins-good
			gstreamer1.0-libav'
		;;
		('video/x-wmv, wmvversion=(int)1')
			package_names='
			gstreamer1.0-libav'
		;;
		(*)
			dependencies_unknown_gstreamer_media_formats_add "$media_format"
			return 0
		;;
	esac

	printf '%s' "$package_names"
}
