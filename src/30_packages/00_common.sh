# write package meta-data
# USAGE: write_metadata [$pkg…]
write_metadata() {
	if [ $# -eq 0 ]; then
		# shellcheck disable=SC2046
		write_metadata $(packages_get_list)
		return 0
	fi

	debug_entering_function 'write_metadata'

	local option_package
	option_package=$(option_value 'package')
	case $option_package in
		('arch')
			for pkg in "$@"; do pkg_write_arch; done
		;;
		('deb')
			for pkg in "$@"; do pkg_write_deb; done
		;;
		('gentoo')
			for pkg in "$@"; do pkg_write_gentoo; done
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
				package_path=$(package_path "$package")
				export pkg="$package" # See TODO
				pkg_build_deb "$package_path"
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

# get ID of given package
# USAGE: package_get_id $package
# RETURNS: package ID, as a non-empty string
package_get_id() {
	# single argument should be the package name
	local package
	package="$1"
	assert_not_empty 'package' 'package_get_id'

	# get package ID from its name
	local package_id
	package_id=$(context_value "${package}_ID")

	# if no package-specific ID is set, fall back to game ID
	if [ -z "$package_id" ]; then
		package_id=$(game_id)
	fi

	# Check that the id fits the format restrictions
	if ! printf '%s' "$package_id" | \
		grep --quiet --regexp='^[0-9a-z][-0-9a-z]\+[0-9a-z]$'
	then
		error_package_id_invalid "$package_id"
		return 1
	fi

	# on Arch Linux, prepend "lib32-" to the ID of 32-bit packages
	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('arch')
			local package_architecture
			package_architecture=$(package_architecture "$package")
			case "$package_architecture" in
				('32')
					package_id="lib32-${package_id}"
				;;
			esac
		;;
	esac

	# on Gentoo, avoid mixups between numbers in package ID and version number
	case "$option_package" in
		('gentoo'|'egentoo')
			package_id=$(printf '%s' "$package_id" | sed 's/-/_/g')
		;;
	esac

	printf '%s' "$package_id"
	return 0
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

# get description for given package
# USAGE: package_get_description $package
# RETURNS: package description, as a non-empty string
package_get_description() {
	# single argument should be the package name
	local package
	package="$1"
	assert_not_empty 'package' 'package_get_description'

	# get package description from its name
	local package_description
	package_description=$(context_value "${package}_DESCRIPTION")

	###
	# TODO
	# Check that $script_version is a non-empty strings
	# Display an explicit error message if it is unset or empty
	###

	# generate a multi-lines or single-line description based on the target package format
	local game_name option_package package_description_full
	game_name=$(game_name)
	option_package=$(option_value 'package')
	case "$option_package" in
		('deb')
			if [ -n "$package_description" ]; then
				package_description_full='Description: %s - %s'
				package_description_full="${package_description_full}"'\n ./play.it script version %s'
				# shellcheck disable=SC2059,SC2154
				package_description_full=$(printf "$package_description_full" "${game_name}" "$package_description" "$script_version")
			else
				package_description_full='Description: %s'
				package_description_full="${package_description_full}"'\n ./play.it script version %s'
				# shellcheck disable=SC2059,SC2154
				package_description_full=$(printf "$package_description_full" "${game_name}" "$script_version")
			fi
		;;
		('arch'|'gentoo')
			if [ -n "$package_description" ]; then
				# shellcheck disable=SC2154
				package_description_full="${game_name} - $package_description - ./play.it script version $script_version"
			else
				# shellcheck disable=SC2154
				package_description_full="${game_name} - ./play.it script version $script_version"
			fi
		;;
	esac

	printf '%s' "$package_description_full"
	return 0
}

# Print the alternative name provided by the given package
# USAGE: package_provide $package
# RETURNS: the provided package id as a non-empty string,
#          or an empty string is none is provided
package_provide() {
	local package
	package="$1"

	local package_provide
	package_provide=$(context_value "${package}_PROVIDE")

	# Return early if no alternative package name is provided by the current package.
	if [ -z "$package_provide" ]; then
		return 0
	fi

	# Apply Gentoo-specific tweaks.
	local option_package
	option_package=$(option_value 'package')
	case "$option_package" in
		('gentoo'|'egentoo')
			package_provide=$(gentoo_package_provide "$package_provide")
		;;
	esac

	printf '%s' "$package_provide"
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
			maintainer=$(sed 's/^PACKAGER="\(.*\)"/\1/' '/etc/makepkg.conf')
		elif grep --quiet "^PACKAGER='.*'" '/etc/makepkg.conf'; then
			maintainer=$(sed "s/^PACKAGER='\\(.*\\)'/\\1/" '/etc/makepkg.conf')
		else
			maintainer=$(sed 's/^PACKAGER=\(.*\)/\1/' '/etc/makepkg.conf')
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

	# Get the version string for the current archive,
	# falling back on "1.0-1" if it is not explicitly set.
	local archive package_version
	archive=$(context_archive)
	if variable_is_empty "${archive}_VERSION"; then
		package_version='1.0-1'
	else
		package_version=$(get_value "${archive}_VERSION")
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
