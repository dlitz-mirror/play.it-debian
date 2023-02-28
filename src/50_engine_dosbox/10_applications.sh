# DOSBox - Print the pre-run actions for the given application.
# These actions are run before spawning DOSBox.
# USAGE: application_prerun_dosbox $application
# RETURN: the pre-run actions, can span over multiple lines,
#         or an empty string if there are none
application_prerun_dosbox() {
	# Game scripts targeting ./play.it < 2.20 have no support for regular pre-run actions.
	if ! version_is_at_least '2.20' "$target_version"; then
		return 0
	fi

	local application
	application="$1"

	get_value "${application}_PRERUN"
}

# DOSBox - Print the post-run actions for the given application.
# These actions are run after exiting DOSBox.
# USAGE: application_postrun_dosbox $application
# RETURN: the post-run actions, can span over multiple lines,
#         or an empty string if there are none
application_postrun_dosbox() {
	# Game scripts targeting ./play.it < 2.20 have no support for regular post-run actions.
	if ! version_is_at_least '2.20' "$target_version"; then
		return 0
	fi

	local application
	application="$1"

	get_value "${application}_POSTRUN"
}

# DOSBox - Print the DOSBox pre-run actions for the given application.
# These actions are run inside DOSBox.
# USAGE: dosbox_prerun $application
# RETURN: the pre-run actions, can span over multiple lines,
#         or an empty string if there are none
dosbox_prerun() {
	# Game scripts targeting ./play.it < 2.20 used to set these actions through APP_xxx_PRERUN.
	if ! version_is_at_least '2.20' "$target_version"; then
		dosbox_prerun_legacy "$application"
		return 0
	fi

	local application
	application="$1"

	get_value "${application}_DOSBOX_PRERUN"
}

# DOSBox - Print the DOSBox post-run actions for the given application.
# These actions are run inside DOSBox.
# USAGE: dosbox_postrun $application
# RETURN: the post-run actions, can span over multiple lines,
#         or an empty string if there are none
dosbox_postrun() {
	# Game scripts targeting ./play.it < 2.20 used to set these actions through APP_xxx_PRERUN.
	if ! version_is_at_least '2.20' "$target_version"; then
		dosbox_postrun_legacy "$application"
		return 0
	fi

	local application
	application="$1"

	get_value "${application}_DOSBOX_POSTRUN"
}
