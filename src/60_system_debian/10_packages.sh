# Print the content of the DEBIAN/control metadata file for the given package
# USAGE: debian_package_metadata_control $package
# RETURN: the contents of the DEBIAN/control file,
#         spanning over multiple lines
debian_package_metadata_control() {
	local package
	package="$1"

	local package_architecture package_depends package_description package_id package_maintainer package_provides package_size package_version
	package_architecture=$(package_architecture_string "$package")
	package_depends=$(package_debian_field_depends "$package")
	package_description=$(package_description "$package")
	package_id=$(package_id "$package")
	package_maintainer=$(package_maintainer)
	package_provides=$(debian_field_provides "$package")
	package_size=$(debian_package_size "$package")
	package_version=$(package_version)

	cat <<- EOF
	Package: $package_id
	Version: $package_version
	Architecture: $package_architecture
	Multi-Arch: foreign
	Maintainer: $package_maintainer
	Installed-Size: $package_size
	Section: non-free/games
	EOF
	if [ -n "$package_provides" ]; then
		cat <<- EOF
		$package_provides
		EOF
	fi
	if [ -n "$package_depends" ]; then
		cat <<- EOF
		Depends: $package_depends
		EOF
	fi
	cat <<- EOF
	Description: $package_description
	EOF
}

# Debian - Write the metadata for the listed packages
# USAGE: debian_packages_metadata $package[…]
debian_packages_metadata() {
	local package
	for package in "$@"; do
		debian_package_metadata_single "$package"
	done
}

# Debian - Write the metadata for the given package
# USAGE: debian_package_metadata_single $package
debian_package_metadata_single() {
	local package
	package="$1"

	# Create metadata directory, enforce correct permissions.
	local package_path control_directory
	package_path=$(package_path "$package")
	control_directory="${package_path}/DEBIAN"
	mkdir --parents "$control_directory"
	chmod 755 "$control_directory"

	# Write main metadata file (DEBIAN/control), enforce correct permissions.
	local control_file
	control_file="${control_directory}/control"
	debian_package_metadata_control "$package" > "$control_file"
	chmod 644 "$control_file"

	# Write postinst/prerm scripts, enforce correct permissions.
	if ! variable_is_empty "${package}_POSTINST_RUN"; then
		local postinst_script postinst_command
		postinst_script="${control_directory}/postinst"
		postinst_command=$(get_value "${package}_POSTINST_RUN")
		cat > "$postinst_script" <<- EOF
		#!/bin/sh -e

		$postinst_command

		exit 0
		EOF
		chmod 755 "$postinst_script"
	fi
	if ! variable_is_empty "${package}_PRERM_RUN"; then
		local prerm_script prerm_command
		prerm_script="${control_directory}/prerm"
		prerm_command=$(get_value "${package}_PRERM_RUN")
		cat > "$prerm_script" <<- EOF
		#!/bin/sh -e

		$prerm_command

		exit 0
		EOF
		chmod 755 "$prerm_script"
	fi
}

# Debian - Build a list of packages
# USAGE: debian_packages_build $package[…]
debian_packages_build() {
	local package
	for package in "$@"; do
		debian_package_build_single "$package"
	done
}

# Debian - Build a single package
# USAGE: debian_package_build_single $package
debian_package_build_single() {
	local package
	package="$1"

	local package_path
	package_path=$(package_path "$package")

	local option_output_dir package_name generated_package_path
	option_output_dir=$(option_value 'output-dir')
	package_name=$(package_name "$package")
	generated_package_path="${option_output_dir}/${package_name}"

	# Skip packages already existing,
	# unless called with --overwrite.
	local option_overwrite
	option_overwrite=$(option_value 'overwrite')
	if \
		[ "$option_overwrite" -eq 0 ] \
		&& [ -e "$generated_package_path" ]
	then
		information_package_already_exists "$package_name"
		return 0
	fi

	# Set compression setting
	local option_compression dpkg_options
	option_compression=$(option_value 'compression')
	dpkg_options=''
	case "$option_compression" in
		('none')
			dpkg_options="${dpkg_options} -Znone"
		;;
		('speed')
			dpkg_options="${dpkg_options} -Zgzip"
		;;
		('size')
			dpkg_options="${dpkg_options} -Zxz"
		;;
		('gzip'|'xz')
			if ! version_is_at_least '2.23' "$target_version"; then
				dpkg_options=$(debian_dpkg_compression_legacy "$dpkg_options" "$option_compression")
			fi
		;;
	esac

	# Use old .deb format if the package is going over the size limit for the modern format
	local package_size
	package_size=$(debian_package_size "$package")
	if [ "$package_size" -gt 9700000 ]; then
		warning_debian_size_limit "$package"
		export PLAYIT_DEBIAN_OLD_DEB_FORMAT=1
		dpkg_options="${dpkg_options} --deb-format=0.939000"
	fi

	# Run the actual package generation, using dpkg-deb
	local package_generation_return_code
	information_package_building "$package_name"
	debug_external_command "TMPDIR=\"$PLAYIT_WORKDIR\" fakeroot -- dpkg-deb $dpkg_options --build \"$package_path\" \"$generated_package_path\" 1>/dev/null"
	set +o errexit
	TMPDIR="$PLAYIT_WORKDIR" fakeroot -- dpkg-deb $dpkg_options \
		--build "$package_path" "$generated_package_path" 1>/dev/null
	package_generation_return_code=$?
	set -o errexit

	if [ $package_generation_return_code -ne 0 ]; then
		error_package_generation_failed "$package_name"
		return 1
	fi
}

# Debian - Compute the package installed size
# USAGE: debian_package_size $package
# RETURN: the package contents size, in kilobytes
debian_package_size() {
	local package
	package="$1"

	# Compute the package size, in kilobytes.
	local package_path package_size
	package_path=$(package_path "$package")
	package_size=$(
		du --total --block-size=1K --summarize "$package_path" | \
			tail --lines=1 | \
			cut --fields=1
	)

	printf '%s' "$package_size"
}

# Debian - Print contents of "Depends" field
# USAGE: package_debian_field_depends $package
package_debian_field_depends() {
	local package
	package="$1"

	local dependencies_list first_item_displayed dependency_string
	dependencies_list=$(dependencies_debian_full_list "$package")
	first_item_displayed=0
	while read -r dependency_string; do
		if [ -z "$dependency_string" ]; then
			continue
		fi
		if [ "$first_item_displayed" -eq 0 ]; then
			printf '%s' "$dependency_string"
			first_item_displayed=1
		else
			printf ', %s' "$dependency_string"
		fi
	done <<- EOF
	$(printf '%s' "$dependencies_list")
	EOF
}

# Debian - Print the contents of the "Conflicts", "Provides" and "Replaces" fields
# USAGE: debian_field_provides $package
debian_field_provides() {
	local package
	package="$1"

	local package_provides
	package_provides=$(package_provides "$package")

	# Return early if there is no package name provided
	if [ -z "$package_provides" ]; then
		return 0
	fi

	local packages_list package_name
	packages_list=''
	while read -r package_name; do
		if [ -z "$packages_list" ]; then
			packages_list="$package_name"
		else
			packages_list="$packages_list, $package_name"
		fi
	done <<- EOL
	$(printf '%s' "$package_provides")
	EOL

	printf 'Conflicts: %s\n' "$packages_list"
	printf 'Provides: %s\n' "$packages_list"
	printf 'Replaces: %s\n' "$packages_list"
}

# Print the file name of the given package
# USAGE: package_name_debian $package
# RETURNS: the file name, as a string
package_name_debian() {
	local package
	package="$1"

	local package_id package_version package_architecture package_name
	package_id=$(package_id "$package")
	package_version=$(package_version)
	package_architecture=$(package_architecture_string "$package")
	package_name="${package_id}_${package_version}_${package_architecture}.deb"

	printf '%s' "$package_name"
}

# Get the path to the directory where the given package is prepared,
# relative to the directory where all packages are stored
# USAGE: package_path_debian $package
# RETURNS: relative path to a directory, as a string
package_path_debian() {
	local package
	package="$1"

	local package_name package_path
	package_name=$(package_name "$package")
	package_path="${package_name%.deb}"

	printf '%s' "$package_path"
}

# Print the architecture string of the given package, in the format expected by dpkg
# USAGE: debian_package_architecture_string $package
# RETURNS: the package architecture, as one of the following values:
#          - i386
#          - amd64
#          - all
debian_package_architecture_string() {
	local package
	package="$1"

	local package_architecture package_architecture_string
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			package_architecture_string='i386'
		;;
		('64')
			package_architecture_string='amd64'
		;;
		('all')
			package_architecture_string='all'
		;;
	esac

	printf '%s' "$package_architecture_string"
}
