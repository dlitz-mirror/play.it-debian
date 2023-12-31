# Gentoo ("egentoo" variant) - Write the metadata for the listed packages
# USAGE: egentoo_packages_metadata $package[…]
egentoo_packages_metadata() {
	local build_deps
	local package_filename
	local ebuild_path
	local inherits

	inherits="xdg"

	# Ensure that $build_deps is set.
	build_deps=$(get_value 'build_deps')

	package_filename="$(egentoo_package_name).tar"

	local option_compression
	option_compression=$(option_value 'compression')
	case $option_compression in
		('speed')
			package_filename="${package_filename}.gz"
		;;
		('size')
			package_filename="${package_filename}.bz2"
		;;
	esac

	local option_output_dir package_id package_name
	option_output_dir=$(option_value 'output-dir')
	package_id="$(egentoo_package_id)"
	package_name="$(egentoo_package_name)"
	mkdir --parents "${option_output_dir}/overlay/games-playit/${package_id}"
	ebuild_path=$(realpath "${option_output_dir}/overlay/games-playit/${package_id}/${package_name}.ebuild")

	local field_keywords field_rdepend field_bdepend
	field_keywords=$(egentoo_field_keywords "$@")
	field_rdepend=$(egentoo_field_rdepend "$@")
	field_bdepend=$(printf "$build_deps")

	cat > "$ebuild_path" << EOF
# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
RESTRICT="fetch strip binchecks"

inherit $inherits

KEYWORDS="$field_keywords"
DESCRIPTION="Ebuild automatically generated with ./play.it"
HOMEPAGE="https://forge.dotslashplay.it/play.it"
SRC_URI="$package_filename"
SLOT="0"

RDEPEND="$field_rdepend"
BDEPEND="$field_bdepend"

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

# Append the required extension to the given package name,
# relying on BINPKG_COMPRESS environment variable.
# USAGE: egentoo_package_filename_auto package_filename
# RETURN: the given package name, with the correct filename extension added,
#         following the current value of BINPKG_COMPRESS
egentoo_package_filename_auto() {
	local package_filename
	package_filename="$1"

	# "zstd" is the default value for BINKPG_COMPRESS,
	# according to make.conf(5) manpage.
	# cf. https://dev.gentoo.org/~zmedico/portage/doc/man/make.conf.5.html
	local package_filename
	case "${BINPKG_COMPRESS:-zstd}" in
		('bzip2')
			package_filename="${package_filename}.bz2"
		;;
		('gzip')
			package_filename="${package_filename}.gz"
		;;
		('lz4')
			package_filename="${package_filename}.lz4"
		;;
		('lzip')
			package_filename="${package_filename}.lz"
		;;
		('lzop')
			package_filename="${package_filename}.lzop"
		;;
		('xz')
			package_filename="${package_filename}.xz"
		;;
		('zstd')
			package_filename="${package_filename}.zst"
		;;
	esac

	printf '%s' "$package_filename"
}

# Print the command that should be used for the generated .tar archive compression,
# relying on BINPKG_COMPRESS environment variable.
# USAGE: egentoo_package_compression_command_auto
# RETURN: the command to use for the generated archive compression,
#         following the current value of BINPKG_COMPRESS
egentoo_package_compression_command_auto() {
	# "zstd" is the default value for BINKPG_COMPRESS,
	# according to make.conf(5) manpage.
	# cf. https://dev.gentoo.org/~zmedico/portage/doc/man/make.conf.5.html
	local compression_command
	case "${BINPKG_COMPRESS:-zstd}" in
		('bzip2')
			compression_command='bzip2'
		;;
		('gzip')
			compression_command='gzip'
		;;
		('lz4')
			compression_command='lz4'
		;;
		('lzip')
			compression_command='lzip'
		;;
		('lzop')
			compression_command='lzop'
		;;
		('xz')
			compression_command='xz'
		;;
		('zstd')
			compression_command='zstd'
		;;
	esac

	printf '%s' "$compression_command"
}

# Gentoo ("egentoo" variant) - Build dummy package
# USAGE: egentoo_packages_build $package[…]
egentoo_packages_build() {
	local option_output_dir package_name package_filename
	option_output_dir=$(option_value 'output-dir')
	mkdir --parents "${option_output_dir}/packages"
	package_name="$(egentoo_package_name)"
	package_filename=$(realpath "${option_output_dir}/packages/${package_name}.tar")

	# Set base tar archiving command and options
	local tar_command tar_options
	tar_command='tar'
	tar_options='--create -P'
	if variable_is_empty 'PLAYIT_TAR_IMPLEMENTATION'; then
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

	# Set compression command and options
	local option_compression compression_command compression_options
	option_compression=$(option_value 'compression')
	case "$option_compression" in
		('speed')
			package_filename="${package_filename}.gz"
			compression_command='gzip'
			compression_options=''
		;;
		('size')
			package_filename="${package_filename}.bz2"
			compression_command='bzip2'
			compression_options=''
		;;
		('auto')
			package_filename=$(egentoo_package_filename_auto "$package_filename")
			compression_command=$(egentoo_package_compression_command_auto)
			compression_options="${BINPKG_COMPRESS_FLAGS:-}"
		;;
	esac
	compression_options="$compression_options --stdout --quiet"

	local option_overwrite package
	option_overwrite=$(option_value 'overwrite')
	if [ -e "$package_filename" ] && [ "$option_overwrite" -eq 0 ]; then
		information_package_already_exists "$(basename "$package_filename")"
		for package in "$@"; do
			eval "${package}"_PKG=\""$package_filename"\"
			export "${package}"_PKG
		done
		return 0
	else
		rm -f "$package_filename"
	fi

	local packages_paths package_path package_architecture
	packages_paths=''
	for package in "$@"; do
		package_path=$(package_path "$package")
		packages_paths="$packages_paths $package_path"
		package_architecture=$(package_architecture "$package")
		case "$package_architecture" in
			('64') tar_options="$tar_options --xform=s:^${package_path}:./amd64:x" ;;
			('32') tar_options="$tar_options --xform=s:^${package_path}:./x86:x" ;;
			(*)    tar_options="$tar_options --xform=s:^${package_path}:./data:x" ;;
		esac
		export "${package}_PKG=$package_filename"
	done

	# Run the actual package generation, using tar
	local package_generation_return_code
	information_package_building "$(basename "$package_filename")"
	if [ -z "$compression_command" ]; then
		debug_external_command "\"$tar_command\" $tar_options --file \"$package_filename\" $packages_paths"
		{
			# shellcheck disable=SC2046
			"$tar_command" $tar_options --file "$package_filename" $packages_paths
			package_generation_return_code=$?
		} || true
	else
		debug_external_command "\"$tar_command\" $tar_options $packages_paths | \"$compression_command\" $compression_options > \"$package_filename\""
		{
			"$tar_command" $tar_options $packages_paths | "$compression_command" $compression_options > "$package_filename"
			package_generation_return_code=$?
		} || true
	fi

	if [ $package_generation_return_code -ne 0 ]; then
		error_package_generation_failed "$package_name"
		return 1
	fi
}

# Get the path to the directory where the given package is prepared,
# relative to the directory where all packages are stored
# USAGE: package_path_egentoo $package
# RETURNS: relative path to a directory, as a string
package_path_egentoo() {
	local package
	package="$1"

	local package_id package_version package_architecture package_path
	package_id=$(package_id "$package")
	package_version=$(package_version)
	package_architecture=$(package_architecture_string "$package")
	package_path="${package_id}_${package_version}_${package_architecture}"

	printf '%s' "$package_path"
}

