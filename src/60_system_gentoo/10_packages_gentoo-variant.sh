# Gentoo - Print path to ebuild file for the given package
# USAGE: gentoo_ebuild_path $package
# RETURN: the path to the .ebuild file
gentoo_ebuild_path() {
	local package
	package="$1"

	local package_id package_name
	package_id=$(package_id "$package")
	package_name=$(package_name "$package")

	printf '%s/%s/gentoo-overlay/games-playit/%s/%s.ebuild' "$PLAYIT_WORKDIR" "$package" "$package_id" "${package_name%.tbz2}"
}

# Gentoo ("gentoo" variant) - Write the metadata for the listed packages
# USAGE: gentoo_packages_metadata $package[…]
gentoo_packages_metadata() {
	local package
	for package in "$@"; do
		gentoo_package_metadata_single "$package"
	done
}

# Gentoo ("gentoo" variant) - Write the metadata for the given package
# USAGE: gentoo_package_metadata_single $package
gentoo_package_metadata_single() {
	local package
	package="$1"

	local package_id overlay_path
	overlay_path="${PLAYIT_WORKDIR}/${package}/gentoo-overlay"

	mkdir --parents "${overlay_path}/metadata"
	cat > "${overlay_path}/metadata/layout.conf" <<- EOF
	masters = gentoo
	EOF

	mkdir --parents "${overlay_path}/profiles"
	cat > "${overlay_path}/profiles/categories" <<- EOF
	games-playit
	EOF

	local package_id package_path
	package_id=$(package_id "$package")
	package_path=$(package_path "$package")
	mkdir --parents "${overlay_path}/games-playit/${package_id}/files"
	ln --symbolic --force --no-target-directory \
		"$package_path" \
		"${overlay_path}/games-playit/${package_id}/files/install"

	local ebuild_path package_architecture ebuild_keywords ebuild_description ebuild_rdepend
	ebuild_path=$(gentoo_ebuild_path "$package")
	ebuild_description=$(package_description "$package")
	ebuild_rdepend=$(package_gentoo_field_rdepend "$package")
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			ebuild_keywords='-* x86 amd64'
		;;
		('64')
			ebuild_keywords='-* amd64'
		;;
		(*)
			ebuild_keywords='x86 amd64' # data packages
		;;
	esac
	cat > "$ebuild_path" <<- EOF
	EAPI=7
	RESTRICT="fetch strip binchecks"
	KEYWORDS="$ebuild_keywords"
	DESCRIPTION="$ebuild_description"
	SLOT="0"
	RDEPEND="$ebuild_rdepend"
	EOF
	cat >> "$ebuild_path" <<- 'EOF'
	src_unpack() {
		mkdir --parents "$S"
	}
	src_install() {
		cp --recursive --link $FILESDIR/install/* $ED/
	}
	EOF

	if ! variable_is_empty "${package}_POSTINST_RUN"; then
		local postinst_command
		postinst_command=$(get_value "${package}_POSTINST_RUN")
		cat >> "$ebuild_path" <<- EOF
		package_postinst() {
		$postinst_command
		}
		EOF
	fi

	if ! variable_is_empty "${package}_PRERM_RUN"; then
		local prerm_command
		prerm_command=$(get_value "${package}_PRERM_RUN")
		cat >> "$ebuild_path" <<- EOF
		package_prerm() {
		$prerm_command
		}
		EOF
	fi
}

# Gentoo ("gentoo" variant) - Build a list of packages
# USAGE: gentoo_packages_build $package[…]
gentoo_packages_build() {
	local package
	for package in "$@"; do
		gentoo_package_build_single "$package"
	done
}

# Gentoo ("gentoo" variant) - Build a single package
# USAGE: gentoo_package_build_single $package
gentoo_package_build_single() {
	local package
	package="$1"

	# Set the path where the package should be generated.
	local option_output_dir package_name generated_package_path generated_package_directory
	option_output_dir=$(option_value 'output-dir')
	package_name=$(package_name "$package")
	generated_package_path="${option_output_dir}/${package_name}"
	generated_package_directory=$(dirname "$generated_package_path")

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
	local option_compression binpkg_compress
	option_compression=$(option_value 'compression')
	case "$option_compression" in
		('speed')
			binpkg_compress='gzip'
		;;
		('size')
			binpkg_compress='bzip2'
		;;
		('auto')
			binpkg_compress=''
		;;
	esac

	# Run the actual package generation, using ebuild
	local ebuild_path package_generation_return_code
	information_package_building "$package_name"
	mkdir --parents "${PLAYIT_WORKDIR}/portage-tmpdir"
	ebuild_path=$(gentoo_ebuild_path "$package")
	ebuild "$ebuild_path" manifest 1>/dev/null
	## The following variables must be exported, otherwise ebuild would not pick them up.
	PORTAGE_TMPDIR="${PLAYIT_WORKDIR}/portage-tmpdir"
	PKGDIR="${PLAYIT_WORKDIR}/gentoo-pkgdir"
	export PORTAGE_TMPDIR PKGDIR
	if [ -n "$binpkg_compress" ]; then
		{
			## The following variable must be exported, otherwise ebuild would not pick it up.
			BINPKG_COMPRESS="$binpkg_compress"
			export BINPKG_COMPRESS
			debug_external_command "fakeroot -- ebuild \"$ebuild_path\" package 1>/dev/null"
			fakeroot -- ebuild "$ebuild_path" package 1>/dev/null
			package_generation_return_code=$?
		} || true
	else
		{
			debug_external_command "fakeroot -- ebuild \"$ebuild_path\" package 1>/dev/null"
			fakeroot -- ebuild "$ebuild_path" package 1>/dev/null
			package_generation_return_code=$?
		} || true
	fi

	if [ $package_generation_return_code -ne 0 ]; then
		error_package_generation_failed "$package_name"
		return 1
	fi

	mkdir --parents "$generated_package_directory"
	mv "${PLAYIT_WORKDIR}/gentoo-pkgdir/games-playit/${package_name}" "$generated_package_path"
	rm --recursive "${PLAYIT_WORKDIR}/portage-tmpdir"
}

# Print the file name of the given package
# USAGE: package_name_gentoo $package
# RETURNS: the file name, as a string
package_name_gentoo() {
	local package
	package="$1"

	local package_id package_version package_name
	package_id=$(package_id "$package")
	package_version=$(package_version)
	package_name="${package_id}-${package_version}.tbz2"

	# Avoid paths collisions when building multiple architecture variants for a same package
	local packages_list current_package current_package_id
	packages_list=$(packages_get_list)
	for current_package in $packages_list; do
		current_package_id=$(package_id "$current_package")
		if \
			[ "$current_package" != "$package" ] \
			&& [ "$current_package_id" = "$package_id" ]
		then
			local package_architecture
			package_architecture=$(package_architecture_string "$package")
			package_name="${package_architecture}/${package_name}"
			break
		fi
	done

	printf '%s' "$package_name"
}

# Get the path to the directory where the given package is prepared,
# relative to the directory where all packages are stored
# USAGE: package_path_gentoo $package
# RETURNS: relative path to a directory, as a string
package_path_gentoo() {
	local package
	package="$1"

	local package_name package_path
	package_name=$(package_name "$package")
	package_path="${package_name%.tbz2}"

	printf '%s' "$package_path"
}

# Tweak the given package version string to ensure it is compatible with portage
# USAGE: gentoo_package_version $package_version
# RETURNS: the package version, as a non-empty string
gentoo_package_version() {
	assert_not_empty 'script_version' 'gentoo_package_version'

	local package_version
	package_version="$1"

	set +o errexit
	package_version=$(
		printf '%s' "$package_version" | \
			grep --extended-regexp --only-matching '^([0-9]{1,18})(\.[0-9]{1,18})*[a-z]?'
	)
	set -o errexit

	if [ -z "$package_version" ]; then
		package_version='1.0'
	fi

	printf '%s_p%s' "$package_version" "$(printf '%s' "$script_version" | sed 's/\.//g')"
}

# Print the architecture string of the given package, in the format expected by portage
# USAGE: gentoo_package_architecture_string $package
# RETURNS: the package architecture, as one of the following values:
#          - x86
#          - amd64
#          - data (dummy value)
gentoo_package_architecture_string() {
	local package
	package="$1"

	local package_architecture package_architecture_string
	package_architecture=$(package_architecture "$package")
	case "$package_architecture" in
		('32')
			package_architecture_string='x86'
		;;
		('64')
			package_architecture_string='amd64'
		;;
		('all')
			# We could put anything here, it should not be used for package metadata.
			package_architecture_string='data'
		;;
	esac

	printf '%s' "$package_architecture_string"
}

# Tweak the given package id to ensure compatibility with portage
# USAGE: gentoo_package_id $package_id
# RETURNS: the package id, as a non-empty string
gentoo_package_id() {
	local package_id
	package_id="$1"

	# Avoid mixups between numbers in package id and version number.
	printf '%s' "$package_id" | sed 's/-/_/g'
}

