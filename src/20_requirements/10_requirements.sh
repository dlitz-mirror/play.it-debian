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
	local option_compression requirements
	option_compression=$(option_value 'compression')
	case "$option_compression" in
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
	local option_checksum requirements
	option_checksum=$(option_value 'checksum')
	case "$option_checksum" in
		('md5')
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
	local option_package requirements
	option_package=$(option_value 'package')
	case "$option_package" in
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
	local option_icons
	option_icons=$(option_value 'icons')
	if [ "$option_icons" -eq 0 ]; then
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

# Check the presence of the current game script requirements
# The requirements specific to the current archive are omitted,
# they are handled by another function: archive_dependencies_check.
# USAGE: check_deps
check_deps() {
	if variable_is_empty 'SCRIPT_DEPS'; then
		SCRIPT_DEPS=''
	fi

	local requirements_list_compression requirements_list_checksum requirements_list_package
	requirements_list_compression=$(requirements_list_compression)
	requirements_list_checksum=$(requirements_list_checksum)
	requirements_list_package=$(requirements_list_package)
	SCRIPT_DEPS="$SCRIPT_DEPS
	$requirements_list_compression
	$requirements_list_checksum
	$requirements_list_package"

	for dep in $SCRIPT_DEPS; do
		case $dep in
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
	local option_icons
	option_icons=$(option_value 'icons')
	if [ "$option_icons" -eq 1 ]; then
		local icons_requirements requirement
		icons_requirements=$(requirements_list_icons)
		for requirement in $icons_requirements; do
			if ! command -v "$requirement" >/dev/null 2>&1; then
				error_dependency_not_found "$requirement"
				return 1
			fi
		done
	fi
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

# returns best available lzip implementation
# fails if lzip is not available
# USAGE: get_lzip_implementation
get_lzip_implementation() {
	for command in 'tarlz' 'plzip' 'lzip'; do
		if command -v "$command" >/dev/null 2>&1; then
			printf '%s' "$command"
			return 0
		fi
	done
	error_dependency_not_found 'lzip'
	return 1
}
