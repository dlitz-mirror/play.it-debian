# write package meta-data
# USAGE: write_metadata [$pkg…]
write_metadata() {
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		write_metadata $(packages_get_list)
		return 0
	fi

	debug_entering_function 'write_metadata'

	local package option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			for package in "$@"; do
				pkg_write_arch "$package"
			done
		;;
		('deb')
			for package in "$@"; do
				pkg_write_deb "$package"
			done
		;;
		('gentoo')
			# FIXME - $pkg should be passed as a function argument, not inherited from the current function
			local pkg
			for package in "$@"; do
				pkg="$package"
				pkg_write_gentoo
			done
		;;
		('egentoo')
			pkg_write_egentoo "$@"
		;;
	esac

	debug_leaving_function 'write_metadata'
}

# Build the final packages.
# USAGE: build_pkg [$pkg…]
build_pkg() {
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		build_pkg $(packages_get_list)
		return 0
	fi

	debug_entering_function 'build_pkg'

	###
	# TODO
	# pkg_build_xxx implicitely depends on the target package being set as $pkg
	# It should instead be passed as a mandatory argument.
	###
	local option_package package package_path
	option_package=$(option_value 'package')
	case $option_package in
		('arch')
			for package in "$@"; do
				package_path=$(package_path "$package")
				export pkg="$package" # See TODO
				pkg_build_arch "$package_path"
			done
		;;
		('deb')
			for package in "$@"; do
				pkg_build_deb "$package"
			done
		;;
		('gentoo')
			for package in "$@"; do
				package_path=$(package_path "$package")
				export pkg="$package" # See TODO
				pkg_build_gentoo "$package_path"
			done
		;;
		('egentoo')
			pkg_build_egentoo "$@"
		;;
	esac

	debug_leaving_function 'build_pkg'
}

# Guess output package type based on current OS
# USAGE: package_format_guess
package_format_guess() {
	# Get OS codename.
	local guessed_host_os
	if [ -e '/etc/os-release' ]; then
		guessed_host_os=$(grep '^ID=' '/etc/os-release' | cut --delimiter='=' --fields=2)
	elif command -v lsb_release >/dev/null 2>&1; then
		guessed_host_os=$(lsb_release --id --short | tr '[:upper:]' '[:lower:]')
	fi

	# Return the most appropriate package type.
	local package_type
	case "$guessed_host_os" in
		( \
			'debian' | \
			'ubuntu' | \
			'linuxmint' | \
			'handylinux' \
		)
			package_type='deb'
		;;
		( \
			'arch' | \
			'artix' | \
			'manjaro' | \
			'manjarolinux' | \
			'endeavouros' | \
			'steamos' \
		)
			package_type='arch'
		;;
		( \
			'gentoo' \
		)
			package_type='gentoo'
		;;
	esac

	# Print guessed package type.
	# This is an empty string if the current OS is not known.
	printf '%s' "$package_type"
}

# Print the full list of packages that should be built from the current archive
# If no value is set to PACKAGES_LIST or some archive-specific variant of PACKAGES_LIST,
# the following default value is returned: "PKG_MAIN".
# USAGE: packages_get_list
# RETURN: a list of package identifiers,
#         separated by spaces or line breaks
packages_get_list() {
	# WARNING - most context-related functions can not be used here,
	#           because context_package relies on the current function.

	local packages_list packages_list_name
	packages_list_name=$(context_name_archive 'PACKAGES_LIST')
	if [ -n "$packages_list_name" ]; then
		packages_list=$(get_value "$packages_list_name")
	elif ! variable_is_empty 'PACKAGES_LIST'; then
		# shellcheck disable=SC2153
		packages_list="$PACKAGES_LIST"
	else
		packages_list='PKG_MAIN'
	fi

	printf '%s' "$packages_list"
}

# Print the list of all the packages that could be built from the current game script,
# not restricted to the current archive.
# USAGE: packages_list_all_archives
# RETURN: a list of package identifiers,
#         separated by line breaks,
#         without duplicates
packages_list_all_archives() {
	# Get the list of archives supported by the current game script.
	local archives_list ARCHIVE
	archives_list=$(archives_return_list)

	# List the packages that could be generated for each supported archive.
	local packages_list_full packages_list package
	packages_list_full=''
	for ARCHIVE in $archives_list; do
		packages_list=$(packages_get_list)
		for package in $packages_list; do
			packages_list_full="$packages_list_full
			$package"
		done
	done

	# Print the full list of packages, one per line, with no duplicates.
	printf '%s\n' $packages_list_full | \
		grep --invert-match --regexp='^$' | \
		sort --unique
}

# Print the list of the packages that would be generated from the given archive.
# USAGE: packages_print_list $archive
# RETURN: a list of package file names, one per line
packages_print_list() {
	local archive
	archive="$1"

	local option_package
	option_package=$(option_value 'package')
	(
		# shellcheck disable=SC2030
		ARCHIVE="$archive"
		case "$option_package" in
			('egentoo')
				local package_name
				package_name=$(egentoo_package_name)
				printf '%s\n' "$package_name"
			;;
			(*)
				local packages_list package package_name
				packages_list=$(packages_get_list)
				for package in $packages_list; do
					package_name=$(package_name "$package")
					printf '%s\n' "$package_name"
				done
			;;
		esac
	)
}

# Print the id of the given package
# USAGE: package_id $package
# RETURNS: the package id, as a non-empty string
package_id() {
	local package
	package="$1"

	local package_id
	package_id=$(context_value "${package}_ID")

	# Fall back to the game id if no package id is explicitly set
	if [ -z "$package_id" ]; then
		package_id=$(game_id)
	fi

	# Check that the id fits the format restrictions.
	if ! printf '%s' "$package_id" | \
		grep --quiet --regexp='^[0-9a-z][-0-9a-z]\+[0-9a-z]$'
	then
		error_package_id_invalid "$package_id"
		return 1
	fi

	# Apply tweaks specific to the target package format.
	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			package_id=$(archlinux_package_id "$package_id")
		;;
		('gentoo'|'egentoo')
			package_id=$(gentoo_package_id "$package_id")
		;;
	esac

	printf '%s' "$package_id"
}

# Print the architecture of the given package
# USAGE: package_architecture $package
# RETURNS: the package architecture, as one of the following values:
#          - 32
#          - 64
#          - all
package_architecture() {
	local package
	package="$1"

	local package_architecture
	package_architecture=$(context_value "${package}_ARCH")

	# If no archive is explictly set for the given package,
	# fall back to "all".
	if [ -z "$package_architecture" ]; then
		package_architecture='all'
	fi

	printf '%s' "$package_architecture"
}

# Print the architecture string of the given package, in the format expected by the packages manager
# USAGE: package_architecture_string $package
# RETURNS: the package architecture, in the format expected by the packages manager
package_architecture_string() {
	local package
	package="$1"

	local option_package package_architecture_string
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			package_architecture_string=$(archlinux_package_architecture_string "$package")
		;;
		('deb')
			package_architecture_string=$(debian_package_architecture_string "$package")
		;;
		('gentoo'|'egentoo')
			package_architecture_string=$(gentoo_package_architecture_string "$package")
		;;
	esac

	printf '%s' "$package_architecture_string"
}

# Print the desciption of the given package
# USAGE: package_description $package
# RETURNS: the package description, a non-empty string
package_description() {
	local package
	package="$1"

	local package_description
	package_description=$(context_value "${package}_DESCRIPTION")

	# Generate a multi-lines or single-line description based on the target package format
	local game_name option_package
	game_name=$(game_name)
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			package_description_oneline "$package"
		;;
		('deb')
			package_description_multilines "$package"
		;;
		('gentoo'|'egentoo')
			package_description_oneline "$package"
		;;
	esac
}

# Print the desciption of the given package, on several lines
# USAGE: package_description_multilines $package
# RETURNS: the package description, a non-empty string,
#          on several lines
package_description_multilines() {
	assert_not_empty 'script_version' 'package_description_multilines'

	local package
	package="$1"

	local game_name package_description
	game_name=$(game_name)
	package_description=$(context_value "${package}_DESCRIPTION")
	if [ -n "$package_description" ]; then
		# Silence the following ShellCheck false positive:
		# script_version is referenced but not assigned.
		# shellcheck disable=SC2154
		printf '%s - %s\n ./play.it script version %s' "$game_name" "$package_description" "$script_version"
	else
		printf '%s\n ./play.it script version %s' "$game_name" "$script_version"
	fi
}

# Print the desciption of the given package, on a single line
# USAGE: package_description_oneline $package
# RETURNS: the package description, a non-empty string,
#          on a single line
package_description_oneline() {
	assert_not_empty 'script_version' 'package_description_oneline'

	local package
	package="$1"

	local game_name package_description
	game_name=$(game_name)
	package_description=$(context_value "${package}_DESCRIPTION")
	if [ -n "$package_description" ]; then
		printf '%s - %s - ./play.it script version %s' "$game_name" "$package_description" "$script_version"
	else
		printf '%s - ./play.it script version %s' "$game_name" "$script_version"
	fi
}

# Print the file name of the given package
# USAGE: package_name $package
# RETURNS: the file name, as a string
package_name() {
	local package
	package="$1"

	local option_package package_name
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			package_name=$(package_name_archlinux "$package")
		;;
		('deb')
			package_name=$(package_name_debian "$package")
		;;
		('gentoo')
			package_name=$(package_name_gentoo "$package")
		;;
		('egentoo')
			package_name=$(egentoo_package_name)
		;;
	esac

	printf '%s' "$package_name"
}

# Get the path to the directory where the given package is prepared.
# USAGE: package_path $package
# RETURNS: path to a directory, it is not checked that it exists or is writable
package_path() {
	local package
	package="$1"

	assert_not_empty 'PLAYIT_WORKDIR' 'package_path'

	local option_package package_name package_path
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			package_path=$(package_path_archlinux "$package")
		;;
		('deb')
			package_path=$(package_path_debian "$package")
		;;
		('gentoo')
			package_path=$(package_path_gentoo "$package")
		;;
		('egentoo')
			package_path=$(package_path_egentoo "$package")
		;;
	esac

	printf '%s/packages/%s' "$PLAYIT_WORKDIR" "$package_path"
}

# Print the maintainer string
# USAGE: package_maintainer
# RETURNS: the package maintainer, as a non-empty string
package_maintainer() {
	local maintainer
	maintainer=''

	# Try to get a maintainer string from environment variables used by Debian tools.
	if ! variable_is_empty 'DEBEMAIL'; then
		if ! variable_is_empty 'DEBFULLNAME'; then
			maintainer="$DEBFULLNAME <${DEBEMAIL}>"
		else
			maintainer="$DEBEMAIL"
		fi
	fi
	if [ -n "$maintainer" ]; then
		printf '%s' "$maintainer"
		return 0
	fi

	# Try to get a maintainer string from /etc/makepkg.conf.
	if \
		[ -r '/etc/makepkg.conf' ] \
		&& grep --quiet '^PACKAGER=' '/etc/makepkg.conf'
	then
		if grep --quiet '^PACKAGER=".*"' '/etc/makepkg.conf'; then
			maintainer=$(sed --silent 's/^PACKAGER="\(.*\)"/\1/p' '/etc/makepkg.conf')
		elif grep --quiet "^PACKAGER='.*'" '/etc/makepkg.conf'; then
			maintainer=$(sed --silent "s/^PACKAGER='\\(.*\\)'/\\1/p" '/etc/makepkg.conf')
		else
			maintainer=$(sed --silent 's/^PACKAGER=\(.*\)/\1/p' '/etc/makepkg.conf')
		fi
	fi
	if [ -n "$maintainer" ]; then
		printf '%s' "$maintainer"
		return 0
	fi

	# Compute a maintainer e-mail from the current hostname and user name,
	# falling back to "user@localhost".
	local hostname
	if command -v 'hostname' >/dev/null 2>&1; then
		hostname=$(hostname)
	elif [ -r '/etc/hostname' ]; then
		hostname=$(cat '/etc/hostname')
	else
		hostname='localhost'
	fi
	local username
	if ! variable_is_empty 'USER'; then
		username="$USER"
	elif command -v 'whoami' >/dev/null 2>&1; then
		username=$(whoami)
	elif command -v 'id' >/dev/null 2>&1; then
		username=$(id --name --user)
	else
		username='user'
	fi
	printf '%s@%s' "$username" "$hostname"
}

# Print the package version string
# USAGE: package_version
# RETURNS: the package version, as a non-empty string
package_version() {
	assert_not_empty 'script_version' 'package_version'

	# Get the version string for the current archive.
	local archive package_version
	archive=$(context_archive)
	package_version=$(get_value "${archive}_VERSION")
	## Fall back on "1.0-1" if no version string is explicitly set.
	if [ -z "$package_version" ]; then
		package_version='1.0-1'
	fi
	package_version="${package_version}+${script_version}"

	# Portage does not like some of our version names
	# cf. https://devmanual.gentoo.org/ebuild-writing/file-format/index.html
	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('gentoo'|'egentoo')
			package_version=$(gentoo_package_version "$package_version")
		;;
	esac

	printf '%s' "$package_version"
}

# Print the list of package names provided by the given package
# This list is used to ensure conflicting packages can not be installed at the same time.
# USAGE: package_provides $package
# RETURN: a list of provided package names,
#         one per line,
#         or an empty string
package_provides() {
	local package
	package="$1"

	local package_provides
	package_provides=$(context_value "${package}_PROVIDES")

	# Fall back to the legacy PKG_xxx_PROVIDE variable,
	# for game scripts targeting ./play.it ≤ 2.23 only.
	if \
		[ -z "$package_provides" ] \
		&& ! version_is_at_least '2.24' "$target_version"
	then
		package_provides=$(package_provide_legacy "$package")
	fi

	# Return early if there is no package name to print
	if [ -z "$package_provides" ]; then
		return 0
	fi

	# Skip empty lines,
	# ignore grep error state if there is nothing to return.
	set +o errexit
	printf '%s' "$package_provides" | \
		grep --invert-match --regexp='^$'
	set -o errexit
}
