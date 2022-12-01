# check script dependencies
# USAGE: check_deps
# NEEDED VARS: (ARCHIVE) (OPTION_CHECKSUM) (OPTION_PACKAGE) (SCRIPT_DEPS)
# CALLS: check_deps_7z error_dependency_not_found icons_list_dependencies
check_deps() {
	case "$OPTION_COMPRESSION" in
		('gzip')
			SCRIPT_DEPS="$SCRIPT_DEPS gzip"
		;;
		('xz')
			SCRIPT_DEPS="$SCRIPT_DEPS xz"
		;;
		('bzip2')
			SCRIPT_DEPS="$SCRIPT_DEPS bzip2"
		;;
		('zstd')
			SCRIPT_DEPS="$SCRIPT_DEPS zstd"
		;;
		('lz4')
			SCRIPT_DEPS="$SCRIPT_DEPS lz4"
		;;
		('lzip')
			SCRIPT_DEPS="$SCRIPT_DEPS lzip"
		;;
		('lzop')
			SCRIPT_DEPS="$SCRIPT_DEPS lzop"
		;;
	esac
	if [ "$OPTION_CHECKSUM" = 'md5sum' ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS md5sum"
	fi
	if [ "$OPTION_PACKAGE" = 'deb' ]; then
		SCRIPT_DEPS="$SCRIPT_DEPS fakeroot dpkg"
	fi
	if [ "$OPTION_PACKAGE" = 'gentoo' ]; then
		# fakeroot-ng doesn't work anymore, fakeroot >=1.25.1 does
		SCRIPT_DEPS="$SCRIPT_DEPS fakeroot:>=1.25.1 ebuild"
	fi
	if [ "$OPTION_PACKAGE" = 'arch' ]; then
		# bsdtar and gzip are required for .MTREE
		SCRIPT_DEPS="$SCRIPT_DEPS bsdtar gzip"
	fi
	for dep in $SCRIPT_DEPS; do
		case $dep in
			('7z')
				archive_dependencies_check_type_7z
			;;
			('debian')
				archive_dependencies_check_type_debian
			;;
			('innoextract')
				archive_dependencies_check_type_innosetup
			;;
			('lha')
				archive_dependencies_check_type_lha
			;;
			('fakeroot'*)
				check_deps_fakeroot "$dep"
			;;
			('lzip')
				get_lzip_implementation >/dev/null
			;;
			(*)
				if ! command -v "$dep" >/dev/null 2>&1; then
					error_dependency_not_found "$dep"
					return 1
				fi
			;;
		esac
	done

	# Check for the dependencies required to extract the icons
	local icons_requirements requirement
	icons_requirements=$(icons_list_dependencies)
	for requirement in $icons_requirements; do
		if ! command -v "$requirement" >/dev/null 2>&1; then
			case "$OPTION_ICONS" in
				('yes')
					error_icon_dependency_not_found "$requirement"
					return 1
				;;
				('auto')
					warning_icon_dependency_not_found "$requirement"
					export SKIP_ICONS=1
					break
				;;
			esac
		fi
	done
}

check_deps_fakeroot() {
	local keyword
	local name
	keyword="$1"
	case "$keyword" in
		('fakeroot:>=1.25.1')
			name='fakeroot (>=1.25.1)'
		;;
		(*)
			name='fakeroot'
		;;
	esac
	if ! command -v 'fakeroot' >/dev/null 2>&1; then
		error_dependency_not_found "$name"
		return 1
	fi

	# Check fakeroot version
	local fakeroot_version
	fakeroot_version="$(LANG=C fakeroot --version | cut --delimiter=' ' --fields=3)"
	case "$keyword" in
		('fakeroot:>=1.25.1')
			if ! version_is_at_least '1.25.1' "$fakeroot_version"; then
				error_dependency_not_found "$name"
				return 1
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
		('dpkg-deb')
			provider='dpkg'
		;;
		(*)
			provider="$command"
		;;
	esac
	printf '%s' "$provider"
	return 0
}

