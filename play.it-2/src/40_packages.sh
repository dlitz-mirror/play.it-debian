# write package meta-data
# USAGE: write_metadata [$pkg…]
# NEEDED VARS: (ARCHIVE) GAME_NAME (OPTION_PACKAGE) (PKG_ARCH) PKG_DEPS_ARCH PKG_DEPS_DEB PKG_DESCRIPTION PKG_ID PKG_PROVIDE
# CALLS: pkg_write_arch pkg_write_deb pkg_write_gentoo testvar
write_metadata() {
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		write_metadata $(packages_get_list)
		return 0
	fi

	debug_entering_function 'write_metadata'

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

		[ "$DRY_RUN" -eq 1 ] && continue

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
			('egentoo')
				pkg_write_egentoo $pkg
			;;
			(*)
				error_invalid_argument 'OPTION_PACKAGE' 'write_metadata'
			;;
		esac
	done
	rm  --force "$postinst" "$prerm"

	debug_leaving_function 'write_metadata'
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

	debug_entering_function 'build_pkg'

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
		case $OPTION_PACKAGE in
			('arch')
				pkg_build_arch "$(package_get_path "$pkg")"
			;;
			('deb')
				pkg_build_deb "$(package_get_path "$pkg")"
			;;
			('gentoo')
				pkg_build_gentoo "$(package_get_path "$pkg")"
			;;
			('egentoo')
				pkg_build_egentoo "$pkg"
			;;
			(*)
				error_invalid_argument 'OPTION_PACKAGE' 'build_pkg'
			;;
		esac
	done

	debug_leaving_function 'build_pkg'
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
	package_id=$(get_context_specific_value 'archive' "${package}_ID")

	# if no package-specific ID is set, fall back to game ID
	if [ -z "$package_id" ]; then
		package_id="$GAME_ID"
	fi

	# on Arch Linux, prepend "lib32-" to the ID of 32-bit packages
	case "$OPTION_PACKAGE" in
		('arch')
			case "$(package_get_architecture "$package")" in
				('32')
					package_id="lib32-${package_id}"
				;;
			esac
		;;
	esac

	# on Gentoo, avoid mixups between numbers in package ID and version number
	case "$OPTION_PACKAGE" in
		('gentoo'|'egentoo')
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
	package_architecture=$(get_context_specific_value 'archive' "${package}_ARCH")

	# if no package-specific architecture is set, fall back to "all"
	if [ -z "$package_architecture" ]; then
		package_architecture='all'
	fi

	printf '%s' "$package_architecture"
	return 0
}

# get architecture string for given package
# USAGE: package_get_architecture_string $package
# RETURNS: package architecture, as a non-empty string, ready to include in package meta-data
package_get_architecture_string() {
	# single argument should be the package name
	# shellcheck disable=SC2039
	local package
	package="$1"
	if [ -z "$package" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_architecture_string' '$package'
		return 1
	fi

	# get package architecture
	# shellcheck disable=SC2039
	local package_architecture
	package_architecture=$(package_get_architecture "$package")

	# set package architecture string, based on its architecture and target package format
	# shellcheck disable=SC2039
	local package_architecture_string
	case "$OPTION_PACKAGE" in
		('arch')
			case "$package_architecture" in
				('32'|'64')
					package_architecture_string='x86_64'
				;;
				(*)
					package_architecture_string='any'
				;;
			esac
		;;
		('deb')
			case "$package_architecture" in
				('32')
					package_architecture_string='i386'
				;;
				('64')
					package_architecture_string='amd64'
				;;
				(*)
					package_architecture_string='all'
				;;
			esac
		;;
		('gentoo'|'egentoo')
			case "$package_architecture" in
				('32')
					package_architecture_string='x86'
				;;
				('64')
					package_architecture_string='amd64'
				;;
				(*)
					package_architecture_string='data' # We could put anything here, it shouldn't be used for package metadata
				;;
			esac
		;;
		(*)
			error_invalid_argument 'OPTION_PACKAGE' 'package_get_architecture_string'
		;;
	esac

	printf '%s' "$package_architecture_string"
	return 0
}

# get description for given package
# USAGE: package_get_description $package
# RETURNS: package description, as a non-empty string
package_get_description() {
	# single argument should be the package name
	# shellcheck disable=SC2039
	local package
	package="$1"
	if [ -z "$package" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_description' '$package'
		return 1
	fi

	# get package description from its name
	# shellcheck disable=SC2039
	local package_description
	package_description=$(get_context_specific_value 'archive' "${package}_DESCRIPTION")

	###
	# TODO
	# Check that $GAME_NAME and $script_version are non-empty strings
	# Display an explicit error message if one is unset or empty
	###

	# generate a multi-lines or single-line description based on the target package format
	# shellcheck disable=SC2039
	local package_description_full
	case "$OPTION_PACKAGE" in
		('deb')
			if [ -n "$package_description" ]; then
				package_description_full='Description: %s - %s'
				package_description_full="${package_description_full}"'\n ./play.it script version %s'
				# shellcheck disable=SC2059,SC2154
				package_description_full=$(printf "$package_description_full" "$GAME_NAME" "$package_description" "$script_version")
			else
				package_description_full='Description: %s'
				package_description_full="${package_description_full}"'\n ./play.it script version %s'
				# shellcheck disable=SC2059,SC2154
				package_description_full=$(printf "$package_description_full" "$GAME_NAME" "$script_version")
			fi
		;;
		('arch'|'gentoo')
			if [ -n "$package_description" ]; then
				# shellcheck disable=SC2154
				package_description_full="$GAME_NAME - $package_description - ./play.it script version $script_version"
			else
				# shellcheck disable=SC2154
				package_description_full="$GAME_NAME - ./play.it script version $script_version"
			fi
		;;
	esac

	printf '%s' "$package_description_full"
	return 0
}

# get "provide" field of given package
# USAGE: package_get_provide $package
# RETURNS: provided package ID as a non-empty string, or an empty string is none is provided
package_get_provide() {
	# single argument should be the package name
	# shellcheck disable=SC2039
	local package
	package="$1"
	if [ -z "$package" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_provide' '$package'
		return 1
	fi

	# get provided package ID from its name
	# shellcheck disable=SC2039
	local package_provide
	package_provide=$(get_context_specific_value 'archive' "${package}_PROVIDE")

	# if no package is provided, return early
	if [ -z "$package_provide" ]; then
		return 0
	fi

	# on Gentoo, avoid mixups between numbers in package ID and version number
	# and add the required "!!games-playit/" prefix to the package ID
	case "$OPTION_PACKAGE" in
		('gentoo')
			package_provide=$(printf '%s' "$package_provide" | sed 's/-/_/g')
			package_provide="!!games-playit/${package_provide}"
		;;
	esac

	printf '%s' "$package_provide"
	return 0
}

# get path to the directory where the given package is prepared
# USAGE: package_get_path $package
# RETURNS: path to a directory, it is not checked that it exists or is writable
package_get_path() {
	# single argument should be the package name
	# shellcheck disable=SC2039
	local package
	package="$1"
	if [ -z "$package" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_path' '$package'
		return 1
	fi


	# check that an archive is set by the global context
	# shellcheck disable=SC2153
	if [ -z "$ARCHIVE" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_name' '$ARCHIVE'
	fi

	# check that PLAYIT_WORKDIR is set by the global context
	if [ -z "$PLAYIT_WORKDIR" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_name' '$PLAYIT_WORKDIR'
	fi

	# compute the package path from its identifier
	# shellcheck disable=SC2039
	local package_path
	package_path="${PLAYIT_WORKDIR}/$(package_get_id "$package")_$(packages_get_version "$ARCHIVE")_$(package_get_architecture_string "$package")"

	printf '%s' "$package_path"
	return 0
}

# get name of the given package’s archive without suffix
# USAGE: package_get_name $package
# RETURNS: filename, without any suffix
package_get_name() {
	# single argument should be the package name
	# shellcheck disable=SC2039
	local package
	package="$1"
	if [ -z "$package" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_name' '$package'
		return 1
	fi

	# check that an archive is set by the global context
	# shellcheck disable=SC2153
	if [ -z "$ARCHIVE" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'package_get_name' '$ARCHIVE'
	fi

	# compute the package path from its identifier
	# shellcheck disable=SC2039
	local package_name
	case "$OPTION_PACKAGE" in
		('arch'|'deb')
			package_name=$(basename "$(package_get_path "$package")")
		;;
		('gentoo'|'egentoo')
			package_name="$(package_get_id "$package")-$(packages_get_version "$ARCHIVE")"
		;;
		(*)
			error_invalid_argument 'OPTION_PACKAGE' 'package_get_name'
		;;
	esac

	printf '%s' "$package_name"
	return 0
}

# get the maintainer string
# USAGE: packages_get_maintainer
# RETURNS: packages maintainer, as a non-empty string
packages_get_maintainer() {
	# get maintainer string from /etc/makepkg.conf
	# shellcheck disable=SC2039
	local maintainer
	if \
		[ -r '/etc/makepkg.conf' ] && \
		grep --quiet '^PACKAGER=' '/etc/makepkg.conf'
	then
		if grep --quiet '^PACKAGER=".*"' '/etc/makepkg.conf'; then
			maintainer=$(sed 's/^PACKAGER="\(.*\)"/\1/' '/etc/makepkg.conf')
		elif grep --quiet "^PACKAGER='.*'" '/etc/makepkg.conf'; then
			maintainer=$(sed "s/^PACKAGER='\\(.*\\)'/\\1/" '/etc/makepkg.conf')
		else
			maintainer=$(sed 's/^PACKAGER=\(.*\)/\1/' '/etc/makepkg.conf')
		fi
	fi

	# return early if we already have a maintainer string
	if [ -n "$maintainer" ]; then
		printf '%s' "$maintainer"
		return 0
	fi

	# get current machine hostname
	# falls back on using "localhost"
	# shellcheck disable=SC2039
	local hostname
	if command -v 'hostname' >/dev/null 2>&1; then
		hostname=$(hostname)
	elif [ -r '/etc/hostname' ]; then
		hostname=$(cat '/etc/hostname')
	else
		hostname='localhost'
	fi

	# get current user name
	# falls back on "user"
	# shellcheck disable=SC2039
	local username
	if [ -n "$USER" ]; then
		username="$USER"
	elif command -v 'whoami' >/dev/null 2>&1; then
		username=$(whoami)
	elif command -v 'id' >/dev/null 2>&1; then
		username=$(id --name --user)
	else
		username='user'
	fi

	printf '%s@%s' "$username" "$hostname"
	return 0
}

# get the packages version string for a given archive
# USAGE: packages_get_version $archive
# RETURNS: packages version, as a non-empty string
packages_get_version() {
	# single argument should be the archive name
	# shellcheck disable=SC2039
	local archive
	archive="$1"
	if [ -z "$archive" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'packages_get_version' '$archive'
		return 1
	fi

	###
	# TODO
	# Check that $script_version is a non-empty string
	# Display an explicit error message if it is unset or empty
	###

	# get the version string for the current archive
	# falls back on "1.0-1"
	# shellcheck disable=SC2039
	local packages_version
	packages_version=$(get_value "${archive}_VERSION")
	if [ -z "$packages_version" ]; then
		packages_version='1.0-1'
	fi
	packages_version="${packages_version}+${script_version}"

	# Portage doesn't like some of our version names (See https://devmanual.gentoo.org/ebuild-writing/file-format/index.html)
	case "$OPTION_PACKAGE" in
		('gentoo'|'egentoo')
			set +o errexit
			packages_version=$(printf '%s' "$packages_version" | grep --extended-regexp --only-matching '^([0-9]{1,18})(\.[0-9]{1,18})*[a-z]?')
			set -o errexit
			if [ -z "$packages_version" ]; then
				packages_version='1.0'
			fi
		;;
	esac

	printf '%s' "$packages_version"
	return 0
}

