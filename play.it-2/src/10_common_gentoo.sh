# get DISTDIR path for Gentoo Linux target
# usage get_distdir_gentoo
# CALLED BY: print_instructions_egentoo
get_distdir_gentoo() {
	local portage_conf_path
	local distdir_path

	portage_conf_path="/etc/portage/make.conf"
	distdir_path=$(grep '^DISTDIR' "${portage_conf_path}"|sed 's/.*="\(.*\)"/\1/')

	printf '%s' "$distdir_path"
}

