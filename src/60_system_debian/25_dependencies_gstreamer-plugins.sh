# Debian - Print the package names providing the GStreamer plugins to decode the formats required by the given package
# USAGE: debian_dependencies_gstreamer_all_formats $package
# RETURN: a list of Debian package names,
#         one per line
debian_dependencies_gstreamer_all_formats() {
	local package
	package="$1"

	local required_media_formats media_format packages_list required_packages
	required_media_formats=$(dependencies_list_gstreamer_media_formats "$package")
	packages_list=''
	while read -r media_format; do
		required_packages=$(debian_dependencies_gstreamer_single_format "$media_format")
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
		('audio/x-wma, wmaversion=(int)1')
			package_names='
			gstreamer1.0-libav'
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
