# Debian - Print the package names providing the commands required by the given package
# USAGE: debian_dependencies_all_commands $package
# RETURN: a list of Debian package names,
#         one per line
debian_dependencies_all_commands() {
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
		required_packages=$(debian_dependencies_single_command "$package" "$command")
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

# Debian - Print the package names providing the required command
# USAGE: debian_dependencies_single_command $package $required_command
# RETURN: a list of Debian package names,
#         one per line
debian_dependencies_single_command() {
	local package required_command
	package="$1"
	required_command="$2"

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
			default-jre | java-runtime'
		;;
		('mono')
			package_names='
			mono-runtime'
		;;
		('mpv')
			package_names='
			mpv:amd64 | mpv'
		;;
		('openmw-iniimporter')
			package_names='
			openmw-launcher'
		;;
		('openmw-launcher')
			package_names='
			openmw-launcher'
		;;
		('pulseaudio')
			package_names='
			pulseaudio:amd64 | pulseaudio'
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
			local package_architecture
			package_architecture=$(package_architecture "$package")
			case "$package_architecture" in
				('32')
					package_names='
					wine32 | wine32-development | wine-stable-i386 | wine-devel-i386 | wine-staging-i386
					wine:amd64 | wine'
				;;
				('64')
					package_names='wine64 | wine64-development | wine-stable-amd64 | wine-devel-amd64 | wine-staging-amd64
					wine'
				;;
			esac
		;;
		('winetricks')
			package_names='
			winetricks
			xterm:amd64 | xterm | zenity:amd64 | zenity | kdialog:amd64 | kdialog'
		;;
		('xgamma')
			package_names='
			x11-xserver-utils:amd64 | x11-xserver-utils'
		;;
		('xrandr')
			package_names='
			x11-xserver-utils:amd64 | x11-xserver-utils'
		;;
		(*)
			dependencies_unknown_command_add "$required_command"
			return 0
		;;
	esac

	printf '%s' "$package_names"
}

