# Keep compatibility with 2.13 and older

icons_include_png_from_directory() {
	icons_include_from_directory "$@"
}

sort_icons() {
	for application in "$@"; do
		icons_include_png_from_directory "$application" "${PLAYIT_WORKDIR}/icons"
	done
}

icon_get_resolution_from_file() {
	resolution=$(icon_get_resolution "$@")
	export resolution
}

use_archive_specific_value() {
	export "$1=$(get_context_specific_value 'archive' "$1")"
}

use_package_specific_value() {
	export "$1=$(get_context_specific_value 'package' "$1")"
}

