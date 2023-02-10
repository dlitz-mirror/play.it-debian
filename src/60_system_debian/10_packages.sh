# write .deb package meta-data
# USAGE: pkg_write_deb
pkg_write_deb() {
	###
	# TODO
	# $pkg should be passed as a function argument, not inherited from the calling function
	###

	local package_path
	package_path=$(package_path "$pkg")

	local pkg_deps pkg_size control_directory control_file postinst_script prerm_script

	control_directory="${package_path}/DEBIAN"
	control_file="$control_directory/control"
	postinst_script="$control_directory/postinst"
	prerm_script="$control_directory/prerm"

	# Get package size
	pkg_size=$(du --total --block-size=1K --summarize "$package_path" | tail --lines=1 | cut --fields=1)

	# Create metadata directory, enforce correct permissions
	mkdir --parents "$control_directory"
	chmod 755 "$control_directory"

	# Write main metadata file, enforce correct permissions
	local archive package_id
	archive=$(context_archive)
	package_id=$(package_get_id "$pkg")
	cat > "$control_file" <<- EOF
	Package: $package_id
	Version: $(packages_get_version "$archive")
	Architecture: $(package_get_architecture_string "$pkg")
	Multi-Arch: foreign
	Maintainer: $(packages_get_maintainer)
	Installed-Size: $pkg_size
	Section: non-free/games
	EOF
	if [ -n "$(package_get_provide "$pkg")" ]; then
		cat >> "$control_file" <<- EOF
		Conflicts: $(package_get_provide "$pkg")
		Provides: $(package_get_provide "$pkg")
		Replaces: $(package_get_provide "$pkg")
		EOF
	fi
	local field_depends
	field_depends=$(package_debian_field_depends "$pkg")
	if [ -n "$field_depends" ]; then
		cat >> "$control_file" <<- EOF
		Depends: $field_depends
		EOF
	fi
	cat >> "$control_file" <<- EOF
	$(package_get_description "$pkg")
	EOF
	chmod 644 "$control_file"

	# Write postinst/prerm scripts, enforce correct permissions
	if ! variable_is_empty "${pkg}_POSTINST_RUN"; then
		cat > "$postinst_script" <<- EOF
		#!/bin/sh -e

		$(get_value "${pkg}_POSTINST_RUN")

		exit 0
		EOF
		chmod 755 "$postinst_script"
	fi

	if ! variable_is_empty "${pkg}_PRERM_RUN"; then
		cat > "$prerm_script" <<- EOF
		#!/bin/sh -e

		$(get_value "${pkg}_PRERM_RUN")

		exit 0
		EOF
		chmod 755 "$prerm_script"
	fi
}

# build .deb package
# USAGE: pkg_build_deb $pkg_path
pkg_build_deb() {
	local option_output_dir pkg_filename
	option_output_dir=$(option_value 'output-dir')
	pkg_filename="${option_output_dir}/$(basename "$1").deb"

	local option_overwrite
	option_overwrite=$(option_value 'overwrite')
	if [ -e "$pkg_filename" ] && [ "$option_overwrite" -eq 0 ]; then
		information_package_already_exists "$(basename "$pkg_filename")"
		return 0
	fi

	local option_compression dpkg_options
	option_compression=$(option_value 'compression')
	case $option_compression in
		('gzip'|'none'|'xz')
			dpkg_options="-Z$option_compression"
		;;
	esac


	information_package_building "$(basename "$pkg_filename")"
	debug_external_command "TMPDIR=\"$PLAYIT_WORKDIR\" fakeroot -- dpkg-deb $dpkg_options --build \"$1\" \"$pkg_filename\" 1>/dev/null"
	TMPDIR="$PLAYIT_WORKDIR" fakeroot -- dpkg-deb $dpkg_options --build "$1" "$pkg_filename" 1>/dev/null
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

	local archive package_id package_version package_architecture package_name
	archive=$(context_archive)
	package_id=$(package_get_id "$package")
	package_version=$(packages_get_version "$archive")
	package_architecture=$(package_get_architecture_string "$package")
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
