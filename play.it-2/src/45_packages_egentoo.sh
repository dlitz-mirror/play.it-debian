# write .ebuild package meta-data
# USAGE: pkg_write_egentoo
# NEEDED VARS: GAME_NAME PKG_DEPS_GENTOO
# CALLED BY: write_metadata
pkg_write_egentoo() {
	local pkg_deps
	local ebuild_path
	local pkg_architectures
	local pkg_filename_base

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

	pkg_filename_base="$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").tar.gz"
	ebuild_path="$PLAYIT_WORKDIR/$pkg/$(package_get_id "$pkg")-$(packages_get_version "$ARCHIVE").ebuild"

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

	cat > "$ebuild_path" <<- EOF
	# Copyright 1999-2021 Gentoo Authors
	# Distributed under the terms of the GNU General Public License v2

	EAPI=7
	RESTRICT="fetch strip binchecks"

	KEYWORDS="$pkg_architectures"
	DESCRIPTION="$(package_get_description "$pkg")"
	SRC_URI="$pkg_filename_base"
	SLOT="0"

	RDEPEND="$pkg_deps"

	pkg_nofetch() {
		elog "Please move $SRC_URI"
		elog "to your distfiles folder."
	}

	src_install() {
		doins -r .
	}

	EOF

	if [ -n "$(get_value "${pkg}_POSTINST_RUN")" ]; then
		cat >> "$ebuild_path" <<- EOF
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
		cat >> "$ebuild_path" <<- EOF
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
