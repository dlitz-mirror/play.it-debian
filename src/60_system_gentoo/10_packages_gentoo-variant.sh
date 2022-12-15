# write .ebuild package meta-data
# USAGE: pkg_write_gentoo
pkg_write_gentoo() {
	###
	# TODO
	# $pkg should be passed as a function argument, not inherited from the calling function
	###

	local package_path package_id
	package_path=$(package_get_path "$pkg")
	package_id=$(package_get_id "$pkg")

	mkdir --parents \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/metadata" \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/profiles" \
		"$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/${package_id}/files"
	printf '%s\n' "masters = gentoo" > "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/metadata/layout.conf"
	printf '%s\n' 'games-playit' > "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/profiles/categories"
	ln --symbolic --force --no-target-directory "$package_path" "$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/${package_id}/files/install"
	local target
	target="$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/${package_id}/${package_id}-$(packages_get_version "$ARCHIVE").ebuild"

	cat > "$target" <<- EOF
	EAPI=7
	RESTRICT="fetch strip binchecks"
	EOF
	local pkg_architectures
	case "$(package_get_architecture "$pkg")" in
		('32')
			pkg_architectures='-* x86 amd64'
		;;
		('64')
			pkg_architectures='-* amd64'
		;;
		(*)
			pkg_architectures='x86 amd64' #data packages
		;;
	esac
	cat >> "$target" <<- EOF
	KEYWORDS="$pkg_architectures"
	DESCRIPTION="$(package_get_description "$pkg")"
	SLOT="0"
	EOF

	# fakeroot >=1.25.1 considers all files belong to root by default
	cat >> "$target" <<- EOF
	RDEPEND="$(package_gentoo_field_rdepend "$pkg")"

	src_unpack() {
		mkdir --parents "\$S"
	}
	src_install() {
		cp --recursive --link \$FILESDIR/install/* \$ED/
	}
	EOF

	if ! variable_is_empty "${pkg}_POSTINST_RUN"; then
		cat >> "$target" <<- EOF
		pkg_postinst() {
		$(get_value "${pkg}_POSTINST_RUN")
		}
		EOF
	fi

	if ! variable_is_empty "${pkg}_PRERM_RUN"; then
		cat >> "$target" <<- EOF
		pkg_prerm() {
		$(get_value "${pkg}_PRERM_RUN")
		}
		EOF
	fi
}

# build .tbz2 gentoo package
# USAGE: pkg_build_gentoo $pkg_path
# NEEDED VARS: (LANG) PLAYIT_WORKDIR
# CALLED BY: build_pkg
pkg_build_gentoo() {
	local pkg_filename_base package_id
	package_id=$(package_get_id "$pkg")
	pkg_filename_base="${package_id}-$(packages_get_version "$ARCHIVE").tbz2"

	# Get packages list for the current game
	local packages_list
	packages_list=$(packages_get_list)

	local current_package_id
	for package in $packages_list; do
		current_package_id=$(package_get_id "$package")
		if [ "$package" != "$pkg" ] && [ "${current_package_id}" = "$package_id" ]; then
			pkg_filename_base="$(package_get_architecture_string "$pkg")/$pkg_filename_base"
			mkdir --parents "$(dirname "$pkg_filename_base")"
		fi
	done
	local pkg_filename
	pkg_filename="$OPTION_OUTPUT_DIR/$pkg_filename_base"

	if [ -e "$pkg_filename" ] && [ $OVERWRITE_PACKAGES -ne 1 ]; then
		information_package_already_exists "$pkg_filename_base"
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg}_PKG
		return 0
	fi

	information_package_building "$pkg_filename_base"

	mkdir --parents "$PLAYIT_WORKDIR/portage-tmpdir"
	local ebuild_path
	ebuild_path="$PLAYIT_WORKDIR/$pkg/gentoo-overlay/games-playit/${package_id}/${package_id}-$(packages_get_version "$ARCHIVE").ebuild"
	ebuild "$ebuild_path" manifest 1>/dev/null
	debug_external_command "PORTAGE_TMPDIR=\"$PLAYIT_WORKDIR/portage-tmpdir\" PKGDIR=\"$PLAYIT_WORKDIR/gentoo-pkgdir\" BINPKG_COMPRESS=\"$OPTION_COMPRESSION\" fakeroot -- ebuild \"$ebuild_path\" package 1>/dev/null"
	PORTAGE_TMPDIR="$PLAYIT_WORKDIR/portage-tmpdir" PKGDIR="$PLAYIT_WORKDIR/gentoo-pkgdir" BINPKG_COMPRESS="$OPTION_COMPRESSION" fakeroot -- ebuild "$ebuild_path" package 1>/dev/null
	mv "$PLAYIT_WORKDIR/gentoo-pkgdir/games-playit/${package_id}-$(packages_get_version "$ARCHIVE").tbz2" "$pkg_filename"
	rm --recursive "$PLAYIT_WORKDIR/portage-tmpdir"

	eval ${pkg}_PKG=\"$pkg_filename\"
	export ${pkg}_PKG
}

# Gentoo - Print "RDEPEND" field
# USAGE: package_gentoo_field_rdepend $package
package_gentoo_field_rdepend() {
	local package
	package="$1"

	local first_item_displayed dependency_string
	first_item_displayed=0
	while read -r dependency_string; do
		if [ -z "$dependency_string" ]; then
			continue
		fi
		# Gentoo policy is that dependencies should be displayed one per line,
		# and indentation is to be done using tabulations.
		if [ "$first_item_displayed" -eq 0 ]; then
			printf '%s' "$dependency_string"
			first_item_displayed=1
		else
			printf '\n\t%s' "$dependency_string"
		fi
	done <<- EOL
	$(dependencies_gentoo_full_list "$package")
	EOL
}

# Print the file name of the given package
# USAGE: package_name_gentoo $package
# RETURNS: the file name, as a string
package_name_gentoo() {
	local package
	package="$1"

	assert_not_empty 'ARCHIVE' 'package_name'

	local package_id package_version package_name
	package_id=$(package_get_id "$package")
	package_version=$(packages_get_version "$ARCHIVE")
	package_name="${package_id}-${package_version}.tbz2"

	local packages_list current_package current_package_id
	packages_list=$(packages_get_list)
	for current_package in $packages_list; do
		current_package_id=$(package_get_id "$current_package")
		if \
			[ "$current_package" != "$package" ] \
			&& [ "$current_package_id" = "$package_id" ]
		then
			local package_architecture
			package_architecture=$(package_get_architecture_string "$package")
			package_name="${package_architecture}/${package_name}"
			break
		fi
	done

	printf '%s' "$package_name"
}
