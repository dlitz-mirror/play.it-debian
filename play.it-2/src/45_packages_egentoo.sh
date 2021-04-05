# write .ebuild package meta-data
# USAGE: pkg_write_egentoo PKG_xxx
# NEEDED VARS: GAME_NAME PKG_DEPS_GENTOO
# CALLED BY: write_metadata
pkg_write_egentoo() {
	local pkg
	local pkg_deps
	local pkg_filename_base
	local pkg_architectures
	local ebuild_path

	pkg="$1"

	use_archive_specific_value "${pkg}_DEPS"
	if [ "$(get_value "${pkg}_DEPS")" ]; then
		#shellcheck disable=SC2046
		pkg_set_deps_gentoo $(get_value "${pkg}_DEPS")
	fi
	use_archive_specific_value "${pkg}_DEPS_GENTOO"
	if [ "$(get_value "${pkg}_DEPS_GENTOO")" ]; then
		pkg_deps="$pkg_deps $(get_value "${pkg}_DEPS_GENTOO")"
	fi
	if [ -n "$(package_get_provide "$pkg")" ]; then
		pkg_deps="${pkg_deps} $(package_get_provide "$pkg")"
	fi

	pkg_filename_base="$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").tar"
	case $OPTION_COMPRESSION in
		('gzip')
			pkg_filename_base="${pkg_filename_base}.gz"
		;;
		('xz')
			pkg_filename_base="${pkg_filename_base}.xz"
		;;
		('bzip2')
			pkg_filename_base="${pkg_filename_base}.bz2"
		;;
		('none') ;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_write_egentoo'
		;;
	esac

	case "$(package_get_architecture "$pkg")" in
		('32')
			pkg_architectures='-* x86 amd64'
		;;
		('64')
			pkg_architectures='-* amd64'
		;;
		(*)
			pkg_architectures='x86 amd64' # data packages
		;;
	esac

	mkdir --parents "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$pkg")"
	ebuild_path=$(realpath "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$pkg")/$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").ebuild")

	cat > "$ebuild_path" << EOF
# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="fetch strip binchecks"

KEYWORDS="$pkg_architectures"
DESCRIPTION="$(package_get_description "$pkg")"
SRC_URI="$pkg_filename_base"
SLOT="0"

RDEPEND="$pkg_deps"

S=\${WORKDIR}

pkg_nofetch() {
	elog "Please move \$SRC_URI"
	elog "to your distfiles folder."
}

src_install() {
	cp --recursive --link \$S/* \$D
}
EOF

	if [ -n "$(get_value "${pkg}_POSTINST_RUN")" ]; then
		cat >> "$ebuild_path" << EOF

pkg_postinst() {
	$(get_value "${pkg}_POSTINST_RUN")
}
EOF

	# For compatibility with pre-2.12 scripts,
	# ignored if a package-specific value is already set
	elif [ -e "$postinst" ]; then
		compat_pkg_write_gentoo_postinst "$ebuild_path"
	fi

	if [ -n "$(get_value "${pkg}_PRERM_RUN")" ]; then
		cat >> "$ebuild_path" << EOF

pkg_prerm() {
	$(get_value "${pkg}_PRERM_RUN")
}
EOF

	# For compatibility with pre-2.12 scripts,
	# ignored if a package-specific value is already set
	elif [ -e "$prerm" ]; then
		compat_pkg_write_gentoo_prerm "$ebuild_path"
	fi
}

# builds dummy egentoo package
# USAGE: pkg_build_egentoo PKG_xxx
# NEEDED VARS: (LANG) PLAYIT_WORKDIR
# CALLED BY: build_pkg
pkg_build_egentoo() {
	local pkg
	local pkg_path
	local pkg_filename
	local tar_options

	pkg="$1"
	pkg_path=$(get_value "${pkg}_PATH")

	# We don’t want both binary packages to overwrite each other
	mkdir --parents "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$pkg")"
	pkg_filename=$(realpath "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$pkg")/$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").tar")

	tar_options='--create'
	if [ -z "$PLAYIT_TAR_IMPLEMENTATION" ]; then
		guess_tar_implementation
	fi
	case "$PLAYIT_TAR_IMPLEMENTATION" in
		('gnutar')
			tar_options="$tar_options --group=root --owner=root"
		;;
		('bsdtar')
			tar_options="$tar_options --gname=root --uname=root"
		;;
		(*)
			error_unknown_tar_implementation
		;;
	esac

	case $OPTION_COMPRESSION in
		('gzip')
			tar_options="$tar_options --gzip"
			pkg_filename="${pkg_filename}.gz"
		;;
		('xz')
			export XZ_DEFAULTS="${XZ_DEFAULTS:=--threads=0}"
			tar_options="$tar_options --xz"
			pkg_filename="${pkg_filename}.xz"
		;;
		('bzip2')
			tar_options="$tar_options --bzip2"
			pkg_filename="${pkg_filename}.bz2"
		;;
		('none') ;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_build_egentoo'
		;;
	esac

	if [ -e "$pkg_filename" ] && [ $OVERWRITE_PACKAGES -ne 1 ]; then
		information_package_alreay_exists "$(basename "$pkg_filename")"
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg?}_PKG
		return 0
	fi

	information_package_building "$(basename "$pkg_filename")"
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '\n'
		eval ${pkg}_PKG=\"$pkg_filename\"
		export ${pkg?}_PKG
		return 0
	fi

	(
		cd "$pkg_path"
		tar $tar_options --file "$pkg_filename" *
	)

	eval ${pkg}_PKG=\"$pkg_filename\"
	export ${pkg?}_PKG

	print_ok
}
