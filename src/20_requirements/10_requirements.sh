# List the requirements for the current game script
# USAGE: requirements_list
# RETURN: a list for required commands, one per line
requirements_list() {
	local requirements_list
	requirements_list=$(
		# List explicit requirements
		if ! variable_is_empty 'SCRIPT_DEPS'; then
			printf '%s\n' $SCRIPT_DEPS
		fi

		# List requirements for the current compression setting
		requirements_list_compression

		# List requirements for the current archive integrity setting
		requirements_list_checksum

		# List requirements for the current output package format setting
		requirements_list_package

		# List requirements for the current icons setting
		requirements_list_icons

		# List requirements for the current archive
		requirements_list_archive
	)

	printf '%s' "$requirements_list" | sort --unique
}

# List requirements for the current compression setting
# USAGE: requirements_list_compression
# RETURN: a list for required commands, one per line
requirements_list_compression() {
	local requirements
	case "$OPTION_COMPRESSION" in
		('gzip')
			requirements='gzip'
		;;
		('xz')
			requirements='xz'
		;;
		('bzip2')
			requirements='bzip2'
		;;
		('zstd')
			requirements='zstd'
		;;
		('lz4')
			requirements='lz4'
		;;
		('lzip')
			requirements='lzip'
		;;
		('lzop')
			requirements='lzop'
		;;
	esac

	if ! variable_is_empty 'requirements'; then
		printf '%s\n' $requirements
	fi
}

# List requirements for the current archive integrity setting
# USAGE: requirements_list_checksum
# RETURN: a list for required commands, one per line
requirements_list_checksum() {
	local requirements
	case "$OPTION_CHECKSUM" in
		('md5sum')
			requirements='md5sum'
		;;
	esac

	if ! variable_is_empty 'requirements'; then
		printf '%s\n' $requirements
	fi
}

# List requirements for the current output package format setting
# USAGE: requirements_list_package
# RETURN: a list for required commands, one per line
requirements_list_package() {
	local requirements
	case "$OPTION_PACKAGE" in
		('arch')
			# bsdtar and gzip are required for .MTREE
			requirements='bsdtar gzip'
		;;
		('deb')
			requirements='fakeroot dpkg-deb'
		;;
		('gentoo')
			# fakeroot-ng doesn't work anymore, fakeroot >=1.25.1 does
			requirements='fakeroot ebuild'
		;;
	esac

	if ! variable_is_empty 'requirements'; then
		printf '%s\n' $requirements
	fi
}

# List requirements for the current icons setting
# USAGE: requirements_list_icons
# RETURN: a list for required commands, one per line
requirements_list_icons() {
	# Return early if icons inclusion is disabled
	if [ "$OPTION_ICONS" = 'no' ]; then
		return 0
	fi

	# Get list of icons
	local icons_list
	icons_list=$(icons_list_all)
	# Return early if there is no icon for the current game script
	if [ -z "$icons_list" ]; then
		return 0
	fi

	# Print requirements for each icon.
	local icon icon_path
	for icon in $icons_list; do
		icon_path=$(icon_path "$icon")
		case "$icon_path" in
			(*'.png')
				printf '%s\n' 'identify'
			;;
			(*'.bmp'|*'.ico')
				printf '%s\n' 'identify' 'convert'
			;;
			(*'.exe')
				printf '%s\n' 'identify' 'convert' 'wrestool'
			;;
		esac
	done
}

# List requirements for the current archive
# USAGE: requirements_list_archive
# RETURN: a list for required commands, one per line
requirements_list_archive() {
	local archive
	archive=$(context_archive)

	{
		requirements_list_archive_single "$archive"
		local archive_part part_index
		for part_index in $(seq 1 9); do
			archive_part="${archive}_PART${part_index}"
			# Stop looking at the first unset archive extra part.
			if variable_is_empty "$archive_part"; then
				break
			fi
			requirements_list_archive_single "$archive_part"
		done
	} | sort --unique
}

# List requirements for the given archive
# USAGE: requirements_list_archive_single $archive
# RETURN: a list for required commands, one per line
requirements_list_archive_single() {
	local archive
	archive="$1"

	local archive_extractor
	archive_extractor=$(archive_extractor "$archive")
	if [ -n "$archive_extractor" ]; then
		printf '%s\n' "$archive_extractor"
		return 0
	fi

	local archive_type requirements
	archive_type=$(archive_get_type "$archive")
	case "$archive_type" in
		('7z')
			requirements='7zr'
		;;
		('cabinet')
			requirements='cabextract'
		;;
		('debian')
			requirements='dpkg-deb'
		;;
		('innosetup')
			requirements='innoextract'
		;;
		('installshield')
			requirements='unshield'
		;;
		('iso')
			requirements='bsdtar'
		;;
		('lha')
			requirements='lha'
		;;
		('mojosetup')
			requirements='bsdtar'
		;;
		('msi')
			requirements='msiextract'
		;;
		('nullsoft-installer')
			requirements='unar'
		;;
		('rar')
			requirements='unar'
		;;
		('tar')
			requirements='tar'
		;;
		('tar.bz2')
			requirements='tar bunzip2'
		;;
		('tar.gz')
			requirements='tar gunzip'
		;;
		('tar.xz')
			requirements='tar unxz'
		;;
		('zip')
			requirements='unzip'
		;;
		('mojosetup_unzip')
			# WARNING - This archive type is deprecated.
			requirements='unzip'
		;;
		('zip_unclean')
			# WARNING - This archive type is deprecated.
			requirements='unzip'
		;;
	esac
	if ! variable_is_empty 'requirements'; then
		printf '%s\n' $requirements
	fi
}

# check script dependencies
# USAGE: check_deps
# NEEDED VARS: (ARCHIVE) (OPTION_CHECKSUM) (OPTION_PACKAGE) (SCRIPT_DEPS)
# CALLS: check_deps_7z error_dependency_not_found icons_list_dependencies
check_deps() {
	if variable_is_empty 'SCRIPT_DEPS'; then
		SCRIPT_DEPS=''
	fi

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
		if \
			! command -v "$requirement" >/dev/null 2>&1 \
			&& [ "$OPTION_ICONS" = 'yes' ]
		then
			error_dependency_not_found "$requirement"
			return 1
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

