# check script dependencies
# USAGE: check_deps
# NEEDED VARS: (ARCHIVE) (OPTION_CHECKSUM) (OPTION_PACKAGE) (SCRIPT_DEPS)
# CALLS: check_deps_7z error_dependency_not_found icons_list_dependencies
check_deps() {
	local archive_type

	if [ "$ARCHIVE" ]; then
		archive_type=$(archive_get_type "$ARCHIVE")
		case "$archive_type" in
			('cabinet')
				SCRIPT_DEPS="$SCRIPT_DEPS cabextract"
			;;
			('debian')
				SCRIPT_DEPS="$SCRIPT_DEPS dpkg"
			;;
			('innosetup1.7'*)
				SCRIPT_DEPS="$SCRIPT_DEPS innoextract1.7"
			;;
			('innosetup'*)
				SCRIPT_DEPS="$SCRIPT_DEPS innoextract"
			;;
			('installshield')
				SCRIPT_DEPS="$SCRIPT_DEPS unshield"
			;;
			('lha')
				SCRIPT_DEPS="$SCRIPT_DEPS lha"
			;;
			('nixstaller')
				SCRIPT_DEPS="$SCRIPT_DEPS gzip tar unxz"
			;;
			('msi')
				SCRIPT_DEPS="$SCRIPT_DEPS msiextract"
			;;
			('mojosetup'|'iso')
				SCRIPT_DEPS="$SCRIPT_DEPS bsdtar"
			;;
			('rar'|'nullsoft-installer')
				SCRIPT_DEPS="$SCRIPT_DEPS unar"
			;;
			('tar')
				SCRIPT_DEPS="$SCRIPT_DEPS tar"
			;;
			('tar.gz')
				SCRIPT_DEPS="$SCRIPT_DEPS gzip tar"
			;;
			('zip'|'zip_unclean'|'mojosetup_unzip')
				SCRIPT_DEPS="$SCRIPT_DEPS unzip"
			;;
		esac
	fi
	if [ "$OPTION_CHECKSUM" = 'md5sum' ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS md5sum"
	fi
	if [ "$OPTION_PACKAGE" = 'deb' ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS fakeroot dpkg"
	fi
	if [ "$OPTION_PACKAGE" = 'gentoo' ]; then
		# fakeroot doesn't work for me, only fakeroot-ng does
		SCRIPT_DEPS="$SCRIPT_DEPS fakeroot-ng ebuild"
	fi
	if [ "$OPTION_PACKAGE" = 'arch' ]; then
		# bsdtar and gzip are required for .MTREE
		SCRIPT_DEPS="$SCRIPT_DEPS bsdtar gzip"
	fi
	for dep in $SCRIPT_DEPS; do
		case $dep in
			('7z')
				check_deps_7z
			;;
			('innoextract'*)
				check_deps_innoextract "$dep"
			;;
			('lha')
				check_deps_lha
			;;
			(*)
				if ! command -v "$dep" >/dev/null 2>&1; then
					error_dependency_not_found "$dep"
				fi
			;;
		esac
	done

	# Check for the dependencies required to extract the icons
	unset ICONS_DEPS
	icons_list_dependencies
	for dep in $ICONS_DEPS; do
		if ! command -v "$dep" >/dev/null 2>&1; then
			case "$OPTION_ICONS" in
				('yes')
					error_icon_dependency_not_found "$dep"
				;;
				('auto')
					warning_icon_dependency_not_found "$dep"
					export SKIP_ICONS=1
					break
				;;
			esac
		fi
	done
}

# check presence of a software to handle .7z archives
# USAGE: check_deps_7z
# CALLS: error_dependency_not_found
# CALLED BY: check_deps
check_deps_7z() {
	for command in '7zr' '7za' 'unar'; do
		if command -v "$command" >/dev/null 2>&1; then
			return 0
		fi
	done
	error_dependency_not_found '7zr'
}

# check presence of a software to handle LHA (.lzh) archives
# USAGE: check_deps_lha
# CALLS: error_dependency_not_found
# CALLED BY: check_deps
check_deps_lha() {
	for command in 'lha' 'bsdtar'; do
		if command -v "$command" >/dev/null 2>&1; then
			return 0
		fi
	done
	error_dependency_not_found 'lha'
}

# check innoextract presence, optionally in a given minimum version
# USAGE: check_deps_innoextract $keyword
# CALLS: error_dependency_not_found
# CALLED BYD: check_deps
check_deps_innoextract() {
	local keyword
	local name
	local version
	local version_major
	local version_minor
	keyword="$1"
	case "$keyword" in
		('innoextract1.7')
			name='innoextract (>= 1.7)'
		;;
		(*)
			name='innoextract'
		;;
	esac
	if ! command -v 'innoextract' >/dev/null 2>&1; then
		error_dependency_not_found "$name"
	fi
	version="$(innoextract --version | head --lines=1 | cut --delimiter=' ' --fields=2)"
	version_minor="${version#*.}"
	version_major="${version%.*}"
	case "$keyword" in
		('innoextract1.7')
			if
				[ "$version_major" -lt 1 ] || \
				[ "$version_major" -lt 2 ] && [ "$version_minor" -lt 7 ]
			then
				error_dependency_not_found "$name"
			fi
		;;
	esac
	return 0
}

# output what a command is provided by
# USAGE: dependency_provided_by $command
# CALLED BY: error_dependency_not_found
dependency_provided_by() {
	local command provider
	command="$1"
	case "$command" in
		('7zr')
			provider='p7zip'
		;;
		('bsdtar')
			provider='libarchive'
		;;
		('convert'|'identify')
			provider='imagemagick'
		;;
		('lha')
			provider='lhasa'
		;;
		('icotool'|'wrestool')
			provider='icoutils'
		;;
		(*)
			provider="$command"
		;;
	esac
	printf '%s' "$provider"
	return 0
}

