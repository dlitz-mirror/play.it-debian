# write package meta-data
# USAGE: write_metadata [$pkg…]
# NEEDED VARS: (ARCHIVE) GAME_NAME (OPTION_PACKAGE) (PKG_ARCH) PKG_DEPS_ARCH PKG_DEPS_DEB PKG_DESCRIPTION PKG_ID (PKG_PATH) PKG_PROVIDE
# CALLS: pkg_write_arch pkg_write_deb pkg_write_gentoo set_architecture testvar
write_metadata() {
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		write_metadata $(packages_get_list)
		return 0
	fi
	local pkg_architecture
	local pkg_description
	local pkg_id
	local pkg_maint
	local pkg_path
	local pkg_provide

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	for pkg in "$@"; do
		if ! testvar "$pkg" 'PKG'; then
			error_invalid_argument 'pkg' 'write_metadata'
		fi
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${packages_list##*$pkg*}" ]; then
			warning_skip_package 'write_metadata' "$pkg"
			continue
		fi

		# Set package-specific variables
		set_architecture "$pkg"
		pkg_id="$(get_value "${pkg}_ID")"
		pkg_maint="$(whoami)@$(hostname 2>/dev/null || cat /etc/hostname)"
		pkg_path="$(get_value "${pkg}_PATH")"
		if [ -z "$pkg_path" ]; then
			error_invalid_argument 'pkg' 'write_metadata'
		fi
		[ "$DRY_RUN" -eq 1 ] && continue
		pkg_provide="$(get_value "${pkg}_PROVIDE")"

		use_archive_specific_value "${pkg}_DESCRIPTION"
		pkg_description="$(get_value "${pkg}_DESCRIPTION")"

		case $OPTION_PACKAGE in
			('arch')
				pkg_write_arch
			;;
			('deb')
				pkg_write_deb
			;;
			('gentoo')
				pkg_write_gentoo
			;;
			(*)
				error_invalid_argument 'OPTION_PACKAGE' 'write_metadata'
			;;
		esac
	done
	rm  --force "$postinst" "$prerm"
}

# build .pkg.tar or .deb package
# USAGE: build_pkg [$pkg…]
# NEEDED VARS: (OPTION_COMPRESSION) (LANG) (OPTION_PACKAGE) (PKG_PATH) PLAYIT_WORKDIR
# CALLS: pkg_build_arch pkg_build_deb pkg_build_gentoo testvar
build_pkg() {
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		build_pkg $(packages_get_list)
		return 0
	fi
	local pkg_path

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	for pkg in "$@"; do
		if ! testvar "$pkg" 'PKG'; then
			error_invalid_argument 'pkg' 'build_pkg'
		fi
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${packages_list##*$pkg*}" ]; then
			warning_skip_package 'build_pkg' "$pkg"
			return 0
		fi
		pkg_path="$(get_value "${pkg}_PATH")"
		if [ -z "$pkg_path" ]; then
			error_invalid_argument 'PKG' 'build_pkg'
		fi
		case $OPTION_PACKAGE in
			('arch')
				pkg_build_arch "$pkg_path"
			;;
			('deb')
				pkg_build_deb "$pkg_path"
			;;
			('gentoo')
				pkg_build_gentoo "$pkg_path"
			;;
			(*)
				error_invalid_argument 'OPTION_PACKAGE' 'build_pkg'
			;;
		esac
	done
}

# guess package format to build from host OS
# USAGE: packages_guess_format $variable_name
# NEEDED VARS: (LANG) DEFAULT_OPTION_PACKAGE
packages_guess_format() {
	local guessed_host_os
	local variable_name
	eval variable_name=\"$1\"
	if [ -e '/etc/os-release' ]; then
		guessed_host_os="$(grep '^ID=' '/etc/os-release' | cut --delimiter='=' --fields=2)"
	elif command -v lsb_release >/dev/null 2>&1; then
		guessed_host_os="$(lsb_release --id --short | tr '[:upper:]' '[:lower:]')"
	fi
	case "$guessed_host_os" in
		('debian'|\
		 'ubuntu'|\
		 'linuxmint'|\
		 'handylinux')
			eval $variable_name=\'deb\'
		;;
		('arch'|\
		 'manjaro'|'manjarolinux'|\
		 'endeavouros')
			eval $variable_name=\'arch\'
		;;
		('gentoo')
			eval $variable_name=\'gentoo\'
		;;
		(*)
			warning_package_format_guessing_failed "$DEFAULT_OPTION_PACKAGE"
			eval $variable_name=\'$DEFAULT_OPTION_PACKAGE\'
		;;
	esac
	export ${variable_name?}
}

# get version of current package, exported as PKG_VERSION
# USAGE: get_package_version
# NEEDED_VARS: PKG
get_package_version() {
	use_package_specific_value "${ARCHIVE}_VERSION"
	PKG_VERSION="$(get_value "${ARCHIVE}_VERSION")"
	if [ -z "$PKG_VERSION" ]; then
		PKG_VERSION='1.0-1'
	fi
	# shellcheck disable=SC2154
	PKG_VERSION="${PKG_VERSION}+$script_version"

	if [ "$OPTION_PACKAGE" = 'gentoo' ]; then
		# Portage doesn't like some of our version names (See https://devmanual.gentoo.org/ebuild-writing/file-format/index.html)
		PKG_VERSION="$(printf '%s' "$PKG_VERSION" | grep --extended-regexp --only-matching '^([0-9]{1,18})(\.[0-9]{1,18})*[a-z]?' || printf '%s' 1)"
	fi

	export PKG_VERSION
}

# get the current package
# USAGE: package_get_current
package_get_current() {
	local package
	package="$PKG"

	# Fall back on a default value if $PKG is not set
	if [ -z "$package" ]; then
		package='PKG_MAIN'
	fi

	printf '%s' "$package"

	return 0
}

# get the full list of packages to generate
# USAGE: packages_get_list
packages_get_list() {
	local packages_list
	packages_list="$PACKAGES_LIST"

	# Fall back on a default list if $PACKAGES_LIST is not set
	if [ -z "$packages_list" ]; then
		packages_list='PKG_MAIN'
	fi

	printf '%s' "$packages_list"

	return 0
}

# get ID of given package
# USAGE: package_get_id $package
# RETURNS: package ID, as a non-empty string
package_get_id() {
	# single argument should be the package name
	# shellcheck disable=SC2039
	local package
	package="$1"
	if [ -z "$package" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_id' '$package'
		return 1
	fi

	# get package ID from its name
	# shellcheck disable=SC2039
	local package_id
	use_archive_specific_value "${package}_ID"
	package_id=$(get_value "${package}_ID")

	# if no package-specific ID is set, fall back to game ID
	if [ -z "$package_id" ]; then
		package_id="$GAME_ID"
	fi

	# on Arch Linux, prepend "lib32-" to the ID of 32-bit packages
	case "$OPTION_PACKAGE" in
		('arch')
			case "$(package_get_architecture)" in
				('32')
					package_id="lib32-${package_id}"
				;;
			esac
		;;
	esac

	# on Gentoo, avoid mixups between numbers in package ID and version number
	case "$OPTION_PACKAGE" in
		('gentoo')
			package_id=$(printf '%s' "$package_id" | sed 's/-/_/g')
		;;
	esac

	printf '%s' "$package_id"
	return 0
}

# get architecture of given package
# USAGE: package_get_architecture $package
# RETURNS: package architecture, as a non-empty string
package_get_architecture() {
	# single argument should be the package name
	# shellcheck disable=SC2039
	local package
	package="$1"
	if [ -z "$package" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_architecture' '$package'
		return 1
	fi

	# get package architecture from its name
	# shellcheck disable=SC2039
	local package_architecture
	use_archive_specific_value "${package}_ARCH"
	package_architecture=$(get_value "${package}_ARCH")

	# if no package-specific architecture is set, fall back to "all"
	if [ -z "$package_architecture" ]; then
		package_architecture='all'
	fi

	printf '%s' "$package_architecture"
	return 0
}

