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

	package_filename="$(egentoo_package_name).tar"
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
	if test -d \$S/data; then
		cp --recursive --link --verbose \$S/data/* \$D || die
	fi

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
	local tar_command
	local tar_options
	local compression_command
	local compression_options
	local packages_paths

	if [ $# -eq 0 ]; then
		error_no_arguments 'pkg_build_egentoo'
	fi

	tar_command="tar"

	local package_name package_filename
	mkdir --parents "$OPTION_OUTPUT_DIR/packages"
	package_name="$(egentoo_package_name)"
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

	tar_options='--create -P'
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

	local package package_path
	if [ -e "$package_filename" ] && [ "$OVERWRITE_PACKAGES" -ne 1 ]; then
		information_package_already_exists "$(basename "$package_filename")"
		for package in "$@"; do
			eval "${package}"_PKG=\""$package_filename"\"
			export "${package}"_PKG
		done
		return 0
	else
		rm -f "$package_filename"
	fi

	for package in "$@"; do
		package_path=$(package_path "$package")
		packages_paths="$packages_paths $package_path"

		case "$(package_get_architecture "$package")" in
			('64') tar_options="$tar_options --xform=s:^${package_path}:./amd64:x" ;;
			('32') tar_options="$tar_options --xform=s:^${package_path}:./x86:x" ;;
			(*)    tar_options="$tar_options --xform=s:^${package_path}:./data:x" ;;
		esac

		eval "${package}"_PKG=\""$package_filename"\"
		export "${package}"_PKG
	done

	information_package_building "$(basename "$package_filename")"

		if [ -z "$compression_command" ]; then
			debug_external_command "\"$tar_command\" $tar_options --file \"$package_filename\" $packages_paths"
			# shellcheck disable=SC2046
			"$tar_command" $tar_options --file "$package_filename" $packages_paths
		else
			debug_external_command "\"$tar_command\" $tar_options $packages_paths | \"$compression_command\" $compression_options > \"$package_filename\""
			"$tar_command" $tar_options $packages_paths | "$compression_command" $compression_options > "$package_filename"
		fi
	}

# Get the path to the directory where the given package is prepared,
# relative to the directory where all packages are stored
# USAGE: package_path_egentoo $package
# RETURNS: relative path to a directory, as a string
package_path_egentoo() {
	local package
	package="$1"

	local archive package_id package_version package_architecture package_path
	archive=$(context_archive)
	package_id=$(package_get_id "$package")
	package_version=$(packages_get_version "$archive")
	package_architecture=$(package_get_architecture_string "$package")
	package_path="${package_id}_${package_version}_${package_architecture}"

	printf '%s' "$package_path"
}
