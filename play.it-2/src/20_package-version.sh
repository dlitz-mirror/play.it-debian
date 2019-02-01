# get version of current package, exported as PKG_VERSION
# USAGE: get_package_version
# NEEDED_VARS: PKG
get_package_version() {
	use_package_specific_value "${ARCHIVE}_VERSION"
	PKG_VERSION="$(get_value "${ARCHIVE}_VERSION")"
	if [ -z "$PKG_VERSION" ]; then
		PKG_VERSION='1.0-1'
	fi
	# shellcheck disable=SC2154
	PKG_VERSION="${PKG_VERSION}+$script_version"

	if [ "$OPTION_PACKAGE" = 'gentoo' ]; then
		PKG_VERSION="$(printf '%s' "$PKG_VERSION" | grep --extended-regexp --only-matching '^([0-9]{1,18})(\.[0-9]{1,18})*[a-z]?' || printf '%s' 1)" # Portage doesn't like some of our version names (See https://devmanual.gentoo.org/ebuild-writing/file-format/index.html)
	fi

	export PKG_VERSION
}

