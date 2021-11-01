# write .ebuild package meta-data
# USAGE: pkg_write_egentoo PKG_xxx
# NEEDED VARS: PKG_DEPS_GENTOO OPTION_COMPRESSION OPTION_OUTPUT_DIR
# CALLED BY: write_metadata
pkg_write_egentoo() {
	local package
	local pkg_deps
	local build_deps
	local postinst_f
	local package_filename
	local package_architectures
	local ebuild_path
	local inherits

	package="$1"
	if [ -z "$package" ];then
		# shellcheck disable=SC2016
		error_empty_string 'pkg_write_egentoo' '$package'
		return 1
	fi

	inherits="xdg"

	local dependencies_string
	dependencies_string=$(get_context_specific_value 'archive' "${package}_DEPS")
	if [ -n "$dependencies_string" ]; then
		# shellcheck disable=SC2046
		pkg_set_deps_gentoo $dependencies_string
	fi

	local dependencies_string_gentoo
	dependencies_string_gentoo=$(get_context_specific_value 'archive' "${package}_DEPS_GENTOO")
	if [ -n "$dependencies_string_gentoo" ]; then
		pkg_deps="$pkg_deps $dependencies_string_gentoo"
	fi

	if [ -n "$(package_get_provide "$package")" ]; then
		pkg_deps="${pkg_deps} $(package_get_provide "$package")"
	fi

	package_filename="$(package_get_name "$package").tar"
	case $OPTION_COMPRESSION in
		('gzip')
			package_filename="${package_filename}.gz"
		;;
		('xz')
			package_filename="${package_filename}.xz"
		;;
		('bzip2')
			package_filename="${package_filename}.bz2"
		;;
		('zstd')
			package_filename="${package_filename}.zst"
			inherits="$inherits unpacker"
			build_deps="$build_deps\\n\\t\$(unpacker_src_uri_depends)"
		;;
		('lzip')
			package_filename="${package_filename}.lz"
			inherits="$inherits unpacker"
			build_deps="$build_deps\\n\\t\$(unpacker_src_uri_depends)"
		;;
		('none') ;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_write_egentoo'
			return 1
		;;
	esac

	case "$(package_get_architecture "$package")" in
		('32')
			package_architectures='-* x86 amd64'
		;;
		('64')
			package_architectures='-* amd64'
		;;
		(*)
			package_architectures='x86 amd64' # data packages
		;;
	esac

	if [ -n "$(get_value "${package}_POSTINST_RUN")" ]; then
		postinst_f="$(get_value "${package}_POSTINST_RUN")"
	# For compatibility with pre-2.12 scripts,
	# ignored if a package-specific value is already set
	elif [ -e "$postinst" ]; then
		postinst_f="$(cat "$postinst")"
	fi

	mkdir --parents "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$package")"
	ebuild_path=$(realpath "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$package")/$(package_get_name "$package").ebuild")

	cat > "$ebuild_path" << EOF
# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="fetch strip binchecks"

inherit $inherits

KEYWORDS="$package_architectures"
DESCRIPTION="$(package_get_description "$package")"
SRC_URI="$package_filename"
SLOT="0"

RDEPEND="$pkg_deps"
BDEPEND="$(printf "$build_deps")"

S=\${WORKDIR}

pkg_nofetch() {
	elog "Please move \$SRC_URI"
	elog "to your distfiles folder."
}

src_install() {
	cp --recursive --link --verbose \$S/* \$D || die
}

pkg_postinst() {
	xdg_pkg_postinst
	$postinst_f
}
EOF

	if [ -n "$(get_value "${package}_PRERM_RUN")" ]; then
		cat >> "$ebuild_path" << EOF

pkg_prerm() {
	$(get_value "${package}_PRERM_RUN")
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
	local package
	local package_path
	local package_filename
	local tar_options

	package="$1"
	if [ -z "$package" ]; then
		# shellcheck disable=SC2016
		error_empty_string 'pkg_build_egentoo' '$package'
		return 1
	fi
	package_path=$(package_get_path "$package")

	# We don’t want both binary packages to overwrite each other
	mkdir --parents "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$package")"
	package_filename=$(realpath "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$package")/$(package_get_name "$package").tar")

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
			return 1
		;;
	esac

	case $OPTION_COMPRESSION in
		('gzip')
			tar_options="$tar_options --gzip"
			package_filename="${package_filename}.gz"
		;;
		('xz')
			export XZ_DEFAULTS="${XZ_DEFAULTS:=--threads=0}"
			tar_options="$tar_options --xz"
			package_filename="${package_filename}.xz"
		;;
		('bzip2')
			tar_options="$tar_options --bzip2"
			package_filename="${package_filename}.bz2"
		;;
		('zstd')
			tar_options="$tar_options --zstd"
			package_filename="${package_filename}.zst"
		;;
		('lzip')
			tar_options="$tar_options --lzip"
			package_filename="${package_filename}.lz"
		;;
		('none') ;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_build_egentoo'
			return 1
		;;
	esac

	if [ -e "$package_filename" ] && [ "$OVERWRITE_PACKAGES" -ne 1 ]; then
		information_package_already_exists "$(basename "$package_filename")"
		eval "${package}"_PKG=\""$package_filename"\"
		export "${package}"_PKG
		return 0
	fi

	information_package_building "$(basename "$package_filename")"
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '\n'
		eval "${package}"_PKG=\""$package_filename"\"
		export "${package}"_PKG
		return 0
	fi

	debug_external_command "tar --directory \"$package_path\" $tar_options --file \"$package_filename\" ."
	# shellcheck disable=SC2046
	tar --directory "$package_path" $tar_options --file "$package_filename" .

	eval "${package}"_PKG=\""$package_filename"\"
	export "${package}"_PKG

	information_package_building_done
}
