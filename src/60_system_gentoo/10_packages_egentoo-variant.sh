# write .ebuild package meta-data
# USAGE: pkg_write_egentoo PKG_xxx
pkg_write_egentoo() {
	local build_deps
	local postinst_f
	local package_filename
	local package_architectures
	local ebuild_path
	local inherits

	local package
	package="$1"
	assert_not_empty 'package' 'pkg_write_egentoo'

	inherits="xdg"

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

RDEPEND="$(package_gentoo_field_rdepend "$package")"
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
	fi
}

# builds dummy egentoo package
# USAGE: pkg_build_egentoo PKG_xxx
pkg_build_egentoo() {
	local package_filename
	local tar_command
	local tar_options
	local compression_command
	local compression_options

	tar_command="tar"

	local package
	package="$1"
	assert_not_empty 'package' 'pkg_build_egentoo'

	local package_path
	package_path=$(package_get_path "$package")

	# We don’t want both binary packages to overwrite each other
	mkdir --parents "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$package")"
	package_filename=$(realpath "$OPTION_OUTPUT_DIR/$(package_get_architecture_string "$package")/$(package_get_name "$package").tar")

	case $OPTION_COMPRESSION in
		('gzip')
			compression_command="gzip"
			package_filename="${package_filename}.gz"
		;;
		('xz')
			compression_command="xz"
			compression_options="--threads=0"
			package_filename="${package_filename}.xz"
		;;
		('bzip2')
			compression_command="bzip2"
			package_filename="${package_filename}.bz2"
		;;
		('zstd')
			compression_command="zstd"
			package_filename="${package_filename}.zst"
		;;
		('lzip')
			compression_command="$(get_lzip_implementation)"
			if [ $compression_command = "tarlz" ]; then
				tar_command="tarlz"
				compression_command=""
				PLAYIT_TAR_IMPLEMENTATION="gnutar"
			else
				compression_options="-0"
				package_filename="${package_filename}.lz"
			fi
		;;
		('none') ;;
		(*)
			error_invalid_argument 'OPTION_COMPRESSION' 'pkg_build_egentoo'
			return 1
		;;
	esac

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

	compression_options="${compression_options} --stdout --quiet"

	if [ -e "$package_filename" ] && [ "$OVERWRITE_PACKAGES" -ne 1 ]; then
		information_package_already_exists "$(basename "$package_filename")"
		eval "${package}"_PKG=\""$package_filename"\"
		export "${package}"_PKG
		return 0
	fi

	information_package_building "$(basename "$package_filename")"

	if [ -z "$compression_command" ]; then
		debug_external_command "\"$tar_command\" --directory \"$package_path\" $tar_options --file \"$package_filename\" ."
		# shellcheck disable=SC2046
		"$tar_command" --directory "$package_path" $tar_options --file "$package_filename" .
	else
		debug_external_command "\"$tar_command\" --directory \"$package_path\" $tar_options . | \"$compression_command\" $compression_options > \"$package_filename\""
		"$tar_command" --directory "$package_path" $tar_options . | "$compression_command" $compression_options > "$package_filename"
	fi

	eval "${package}"_PKG=\""$package_filename"\"
	export "${package}"_PKG
}
