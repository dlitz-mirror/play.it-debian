# Unreal Engine 4 - Print a default list of required GStreamer decoders
# USAGE: unrealengine4_dependencies_list_gstreamer_decoders_default $package
# RETURNS: a list of GStreamer decoders, one per line,
#          the list can be empty.
unrealengine4_dependencies_list_gstreamer_decoders_default() {
	local package
	package="$1"

	# Return early if the current package should not depend on GStreamer plugins
	local package_architecture
	package_architecture=$(package_architecture "$package")
	if [ "$package_architecture" = 'all' ]; then
		return 0
	fi

	local applications_list application application_type
	applications_list=$(applications_list)
	if [ -z "$applications_list" ]; then
		error_applications_list_empty
	fi
	## FIXME - Trim leading spaces from the application list, this should be done by the applications_list function.
	application=$(printf '%s' "$applications_list" | grep --only-matching '[^ ].*' | cut --delimiter=' ' --fields=1)
	application_type=$(application_type "$application")

	local gstreamer_decoders
	case "$application_type" in
		('wine')
			gstreamer_decoders='
			video/quicktime, variant=(string)iso'
		;;
	esac

	printf '%s' "${gstreamer_decoders:-}"
}

