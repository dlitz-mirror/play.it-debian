# print installation instructions
# USAGE: print_instructions $pkg[…]
# NEEDED VARS: (GAME_NAME) (OPTION_PACKAGE)
print_instructions() {
	[ "$GAME_NAME" ] || return 1
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		print_instructions $(packages_get_list)
		return 0
	fi
	local package_arch
	local packages_list_32
	local packages_list_64
	local packages_list_all
	local string
	for package in "$@"; do
		package_arch="$(get_value "${package}_ARCH")"
		case "$package_arch" in
			('32')
				packages_list_32="$packages_list_32 $package"
			;;
			('64')
				packages_list_64="$packages_list_64 $package"
			;;
			(*)
				packages_list_all="$packages_list_all $package"
			;;
		esac

	done
	if [ "$OPTION_PACKAGE" = 'gentoo' ] && [ -n "$GENTOO_OVERLAYS" ]; then
		information_required_gentoo_overlays "$GENTOO_OVERLAYS"
	fi
	if [ "$OPTION_PACKAGE" = 'egentoo' ]; then
		info_local_overlay_gentoo
	fi
	information_installation_instructions_common "$GAME_NAME"
	if [ -n "$packages_list_32" ] && [ -n "$packages_list_64" ]; then
		print_instructions_architecture_specific '32' $packages_list_all $packages_list_32
		print_instructions_architecture_specific '64' $packages_list_all $packages_list_64
	else
		case $OPTION_PACKAGE in
			('arch')
				print_instructions_arch "$@"
			;;
			('deb')
				print_instructions_deb "$@"
			;;
			('gentoo')
				print_instructions_gentoo "$@"
			;;
			('egentoo')
				print_instructions_egentoo "$@"
			;;
			(*)
				error_invalid_argument 'OPTION_PACKAGE' 'print_instructions'
			;;
		esac
	fi
	printf '\n'
}

# print installation instructions, for a given architecture
# USAGE: print_instructions_architecture_specific $pkg[…]
# CALLS: print_instructions_arch print_instructions_deb print_instructions_gentoo
print_instructions_architecture_specific() {
	local architecture_variant
	architecture_variant="${1}-bit"
	information_installation_instructions_variant "$architecture_variant"
	shift 1
	case $OPTION_PACKAGE in
		('arch')
			print_instructions_arch "$@"
		;;
		('deb')
			print_instructions_deb "$@"
		;;
		('gentoo')
			print_instructions_gentoo "$@"
		;;
		('egentoo')
			print_instructions_egentoo "$@"
		;;
		(*)
			error_invalid_argument 'OPTION_PACKAGE' 'print_instructions'
		;;
	esac
}

