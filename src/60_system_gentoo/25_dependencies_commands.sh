# Gentoo - Print the package names providing the commands required by the given package
# USAGE: gentoo_dependencies_all_commands $package
# RETURN: a list of Gentoo package names,
#         one per line
gentoo_dependencies_all_commands() {
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
		required_packages=$(gentoo_dependencies_single_command "$package" "$command")
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

# Gentoo - Print the package names providing the required command
# USAGE: gentoo_dependencies_single_command $package $required_command
# RETURN: a list of Gentoo package names,
#         one per line
gentoo_dependencies_single_command() {
	local package required_command
	package="$1"
	required_command="$2"


	local package_names
	case "$required_command" in
		('dosbox')
			package_names='
			games-emulation/dosbox'
		;;
		('java')
			package_names='
			virtual/jre'
		;;
		('mono')
			package_names='
			dev-lang/mono'
		;;
		('pulseaudio')
			package_names='
			media-sound/pulseaudio'
		;;
		('scummvm')
			package_names='
			games-engines/scummvm'
		;;
		('wine')
			local package_architecture
			package_architecture=$(package_architecture "$package")
			case "$package_architecture" in
				('32')
					package_names='
					virtual/wine[abi_x86_32]'
				;;
				('64')
					package_names='
					virtual/wine[abi_x86_64]'
				;;
			esac
		;;
		('winetricks')
			## TODO - Add an OR dependency on one of these packages:
			## - x11-terms/xterm
			## - gnome-extra/zenity
			## - kde-apps/kdialog
			## This dependency must be set on a single line.
			package_names='
			app-emulation/winetricks'
		;;
		('xgamma')
			package_names='
			x11-apps/xgamma'
		;;
		('xrandr')
			package_names='
			x11-apps/xrandr'
		;;
		(*)
			dependencies_unknown_command_add "$required_command"
			return 0
		;;
	esac

	printf '%s' "$package_names"
}

