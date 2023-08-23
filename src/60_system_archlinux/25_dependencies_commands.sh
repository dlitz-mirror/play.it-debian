# Arch Linux - Print the package names providing the commands required by the given package
# USAGE: archlinux_dependencies_all_commands $package
# RETURN: a list of Arch Linux package names,
#         one per line
archlinux_dependencies_all_commands() {
	local package
	package="$1"

	local required_commands
	required_commands=$(dependencies_list_commands "$package")
	# Return early if the current package does not require any command
	if [ -z "$required_commands" ]; then
		return 0
	fi

	local command packages_list required_packages
	packages_list=''
	while read -r command; do
		required_packages=$(archlinux_dependencies_single_command "$command")
		packages_list="$packages_list
		$required_packages"
	done <<- EOL
	$(printf "$required_commands")
	EOL

	printf '%s' "$packages_list" | \
		sed 's/^\s*//g' | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Arch Linux - Print the package names providing the required command
# USAGE: archlinux_dependencies_single_command $required_command
# RETURN: a list of Arch Linux package names,
#         one per line
archlinux_dependencies_single_command() {
	local required_command
	required_command="$1"

	local package_names
	case "$required_command" in
		('dos2unix')
			package_names='
			dos2unix'
		;;
		('dosbox')
			package_names='
			dosbox'
		;;
		('java')
			package_names='
			jre8-openjdk'
		;;
		('mono')
			package_names='
			mono'
		;;
		('mpv')
			package_names='
			mpv'
		;;
		('openmw-iniimporter')
			package_names='
			openmw'
		;;
		('openmw-launcher')
			package_names='
			openmw'
		;;
		('pulseaudio')
			package_names='
			pulseaudio'
		;;
		('scummvm')
			package_names='
			scummvm'
		;;
		('vcmilauncher')
			package_names='
			vcmi'
		;;
		('wine')
			package_names='
			wine'
		;;
		('winetricks')
			package_names='
			winetricks
			xterm'
		;;
		('xgamma')
			package_names='
			xorg-xgamma'
		;;
		('xrandr')
			package_names='
			xorg-xrandr'
		;;
		(*)
			dependencies_unknown_command_add "$required_command"
			return 0
		;;
	esac

	printf '%s' "$package_names"
}

