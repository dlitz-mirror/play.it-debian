# write package meta-data
# USAGE: write_metadata [$pkg…]
# NEEDED VARS: (ARCHIVE) GAME_NAME (OPTION_PACKAGE) PACKAGES_LIST (PKG_ARCH) PKG_DEPS_ARCH PKG_DEPS_DEB PKG_DESCRIPTION PKG_ID (PKG_PATH) PKG_PROVIDE
# CALLS: pkg_write_arch pkg_write_deb pkg_write_gentoo set_architecture testvar
write_metadata() {
	if [ $# -eq 0 ]; then
		write_metadata $PACKAGES_LIST
		return 0
	fi
	local pkg_architecture
	local pkg_description
	local pkg_id
	local pkg_maint
	local pkg_path
	local pkg_provide
	for pkg in "$@"; do
		if ! testvar "$pkg" 'PKG'; then
			error_invalid_argument 'pkg' 'write_metadata'
		fi
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${PACKAGES_LIST##*$pkg*}" ]; then
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
# NEEDED VARS: (OPTION_COMPRESSION) (LANG) (OPTION_PACKAGE) PACKAGES_LIST (PKG_PATH) PLAYIT_WORKDIR
# CALLS: pkg_build_arch pkg_build_deb pkg_build_gentoo testvar
build_pkg() {
	if [ $# -eq 0 ]; then
		build_pkg $PACKAGES_LIST
		return 0
	fi
	local pkg_path
	for pkg in "$@"; do
		if ! testvar "$pkg" 'PKG'; then
			error_invalid_argument 'pkg' 'build_pkg'
		fi
		if [ "$OPTION_ARCHITECTURE" != all ] && [ -n "${PACKAGES_LIST##*$pkg*}" ]; then
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

