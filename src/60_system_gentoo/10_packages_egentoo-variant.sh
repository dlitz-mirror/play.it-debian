# write .ebuild package meta-data
# USAGE: pkg_write_egentoo PKG_xxx
pkg_write_egentoo() {
	local build_deps
	local package_filename
	local ebuild_path
	local inherits

	if [ $# -eq 0 ]; then
		error_no_arguments 'pkg_write_egentoo'
	fi

	inherits="xdg"

	# Ensure that $build_deps is set.
	if ! variable_is_set 'build_deps'; then
		build_deps=''
	fi

	package_filename="$(egentoo_package_id).tar"
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

	local package_id package_name
	package_id="$(egentoo_package_id)"
	package_name="$(egentoo_package_name)"
	mkdir --parents "$OPTION_OUTPUT_DIR/overlay/games-playit/${package_id}"
	ebuild_path=$(realpath "$OPTION_OUTPUT_DIR/overlay/games-playit/${package_id}/${package_name}.ebuild")

	cat > "$ebuild_path" << EOF
# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="fetch strip binchecks"

inherit $inherits

KEYWORDS="$(egentoo_field_keywords "$@")"
DESCRIPTION="Ebuild automatically generated with ./play.it"
HOMEPAGE="https://forge.dotslashplay.it/play.it"
SRC_URI="$package_filename"
SLOT="0"

RDEPEND="$(egentoo_field_rdepend "$@")"
BDEPEND="$(printf "$build_deps")"

S=\${WORKDIR}

pkg_nofetch() {
	elog "Please move \$SRC_URI"
	elog "to your distfiles folder."
}

src_install() {
	cp --recursive --link --verbose \$S/data/* \$D || die

	if use x86 && test -d \$S/x86; then
		cp --recursive --link --verbose \$S/x86/* \$D || die
	elif use amd64; then
		if test -d \$S/amd64; then
			cp --recursive --link --verbose \$S/amd64/* \$D || die
		elif test -d \$S/x86; then
			cp --recursive --link --verbose \$S/x86/* \$D || die
		fi
	fi
}
EOF
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

	local package_path package_name
	package_path=$(package_get_path "$package")
	package_name="$(package_get_name "$package")"

	mkdir --parents "$OPTION_OUTPUT_DIR/packages"
	package_filename=$(realpath "$OPTION_OUTPUT_DIR/packages/${package_name}.tar")

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
