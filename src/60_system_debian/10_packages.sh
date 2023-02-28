# Print the content of the DEBIAN/control metadata file for the given package
# USAGE: debian_package_metadata_control $package
# RETURN: the contents of the DEBIAN/control file,
#         spanning over multiple lines
debian_package_metadata_control() {
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

	local package_architecture package_depends package_description package_id package_maintainer package_version
	package_architecture=$(package_architecture_string "$package")
	package_depends=$(package_debian_field_depends "$package")
	package_description=$(package_description "$package")
	package_id=$(package_id "$package")
	package_maintainer=$(package_maintainer)
	package_provide=$(package_provide "$package")
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
	if [ -n "$package_provide" ]; then
		cat <<- EOF
		Conflicts: $package_provide
		Provides: $package_provide
		Replaces: $package_provide
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

# Write the metadata for the given package
# WARNING: The target package is set in write_metadata,
#          and passed through a $pkg variable implicitly inherited.
# USAGE: pkg_write_deb $package
pkg_write_deb() {
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
		local postinst_script
		postinst_script="${control_directory}/postinst"
		cat > "$postinst_script" <<- EOF
		#!/bin/sh -e

		$(get_value "${package}_POSTINST_RUN")

		exit 0
		EOF
		chmod 755 "$postinst_script"
	fi
	if ! variable_is_empty "${package}_PRERM_RUN"; then
		local prerm_script
		prerm_script="${control_directory}/prerm"
		cat > "$prerm_script" <<- EOF
		#!/bin/sh -e

		$(get_value "${package}_PRERM_RUN")

		exit 0
		EOF
		chmod 755 "$prerm_script"
	fi
}

# Build a .deb package from the given path
# USAGE: pkg_build_deb $package_path
pkg_build_deb() {
	local package_path
	package_path="$1"

	local option_output_dir generated_package_name generated_package_path
	option_output_dir=$(option_value 'output-dir')
	generated_package_name=$(basename "$package_path")
	generated_package_path="${option_output_dir}/${generated_package_name}.deb"

	# Skip packages already existing,
	# unless called with --overwrite.
	local option_overwrite
	option_overwrite=$(option_value 'overwrite')
	if \
		[ "$option_overwrite" -eq 0 ] \
		&& [ -e "$generated_package_path" ]
	then
		information_package_already_exists "${generated_package_name}.deb"
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

	# Run the actual package generation, using dpkg-deb
	information_package_building "${generated_package_name}.deb"
	debug_external_command "TMPDIR=\"$PLAYIT_WORKDIR\" fakeroot -- dpkg-deb $dpkg_options --build \"$package_path\" \"$generated_package_path\" 1>/dev/null"
	TMPDIR="$PLAYIT_WORKDIR" fakeroot -- dpkg-deb $dpkg_options \
		--build "$package_path" "$generated_package_path" 1>/dev/null
}

# Debian - Print contents of "Depends" field
# USAGE: package_debian_field_depends $package
package_debian_field_depends() {
	local package
	package="$1"

	local first_item_displayed dependency_string
	local first_item_displayed=0
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
	$(dependencies_debian_full_list "$package")
	EOF
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
