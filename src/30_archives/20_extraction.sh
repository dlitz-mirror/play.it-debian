# Check that the tools required to extract the content of a given archive are available,
# including the archive extra parts.
# USAGE: archive_dependencies_check $archive
archive_dependencies_check() {
	local archive
	archive="$1"
	assert_not_empty 'archive' 'archive_dependencies_check'

	# Check extraction dependencies for main archive.
	archive_dependencies_check_single "$archive"

	# Check extraction dependencies for archive extra parts.
	local archive_part
	for i in $(seq 1 9); do
		archive_part="${archive}_PART${i}"
		# Stop looking at the first unset archive extra part.
		if variable_is_empty "$archive_part"; then
			break
		fi
		archive_dependencies_check_single "$archive_part"
	done
}

# Check that the tools required to extract the content of a given single archive are available.
# USAGE: archive_dependencies_check_single $archive
archive_dependencies_check_single() {
	local archive
	archive="$1"
	assert_not_empty 'archive' 'archive_dependencies_check_single'

	local archive_extractor
	archive_extractor=$(archive_extractor "$archive")
	if [ -n "$archive_extractor" ]; then
		archive_dependencies_check_using_extractor "$archive"
	else
		archive_dependencies_check_from_type "$archive"
	fi
}

# Check that the tools required to extract the content of a given archive are available.
#
# Check the presence of the specific tools required to provide the given archive extractor.
#
# USAGE: archive_dependencies_check_using_extractor $archive
archive_dependencies_check_using_extractor() {
	local archive
	archive="$1"
	assert_not_empty 'archive' 'archive_dependencies_check'

	local archive_extractor
	archive_extractor=$(archive_extractor "$archive")
	case "$archive_extractor" in
		( \
			'7za' | \
			'7zr' | \
			'bsdtar' | \
			'cabextract' | \
			'dpkg-deb' | \
			'innoextract' | \
			'lha' | \
			'msiextract' | \
			'tar' | \
			'unar' | \
			'unshield' | \
			'unzip' \
		)
			# Supported extractor, no error to throw.
		;;
		(*)
			error_archive_extractor_invalid "$archive_extractor"
			return 1
		;;
	esac

	if ! command -v "$archive_extractor" >/dev/null 2>&1; then
		error_dependency_not_found "$archive_extractor"
		return 1
	fi
}

# Check that the tools required to extract the content of a given archive are available.
#
# Check the presence of any tool supporting the given archive type.
#
# USAGE: archive_dependencies_check_from_type $archive
archive_dependencies_check_from_type() {
	local archive
	archive="$1"
	assert_not_empty 'archive' 'archive_dependencies_check'

	local archive_type
	archive_type=$(archive_get_type "$archive")
	case "$archive_type" in
		('7z')
			archive_dependencies_check_type_7z
		;;
		('cabinet')
			archive_dependencies_check_type_cabinet
		;;
		('debian')
			archive_dependencies_check_type_debian
		;;
		('innosetup')
			archive_dependencies_check_type_innosetup
		;;
		('innosetup_nolowercase')
			archive_dependencies_check_type_innosetup
		;;
		('installshield')
			archive_dependencies_check_type_installshield
		;;
		('iso')
			archive_dependencies_check_type_iso
		;;
		('lha')
			archive_dependencies_check_type_lha
		;;
		('makeself')
			archive_requirements_makeself_check
		;;
		('mojosetup')
			archive_requirements_mojosetup_check
		;;
		('mojosetup_unzip')
			# WARNING - This archive type is deprecated.
			archive_requirements_mojosetup_check
		;;
		('msi')
			archive_dependencies_check_type_msi
		;;
		('nullsoft-installer')
			archive_dependencies_check_type_nullsoft
		;;
		('rar')
			archive_dependencies_check_type_rar
		;;
		('tar')
			archive_dependencies_check_type_tar
		;;
		('tar.bz2')
			archive_dependencies_check_type_tarbz2
		;;
		('tar.gz')
			archive_dependencies_check_type_targz
		;;
		('tar.xz')
			archive_dependencies_check_type_tarxz
		;;
		('zip')
			archive_dependencies_check_type_zip
		;;
		('zip_unclean')
			archive_dependencies_check_type_zip
		;;
	esac
}

# extract data from a given archive file
# USAGE: archive_extraction $archive
archive_extraction() {
	local archive
	archive="$1"

	local archive_path archive_name
	archive_path=$(archive_find_path "$archive")
	archive_name=$(basename "$archive_path")

	information_archive_data_extraction "$archive_name"

	local destination_directory
	destination_directory="${PLAYIT_WORKDIR}/gamedata"
	mkdir --parents "$destination_directory"

	local archive_extractor
	archive_extractor=$(archive_extractor "$archive")
	if [ -n "$archive_extractor" ]; then
		archive_extraction_using_extractor "$archive" "$destination_directory"
	else
		archive_extraction_from_type "$archive" "$destination_directory"
	fi
}

# extract data from the target archive, using the specified extractor
# USAGE: archive_extraction_using_extractor $archive $destination_directory
archive_extraction_using_extractor() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_extractor
	archive_extractor=$(archive_extractor "$archive")
	case "$archive_extractor" in
		('7za')
			archive_extraction_using_7za "$archive" "$destination_directory"
		;;
		('7zr')
			archive_extraction_using_7zr "$archive" "$destination_directory"
		;;
		('bsdtar')
			archive_extraction_using_bsdtar "$archive" "$destination_directory"
		;;
		('cabextract')
			archive_extraction_using_cabextract "$archive" "$destination_directory"
		;;
		('dpkg-deb')
			archive_extraction_using_dpkgdeb "$archive" "$destination_directory"
		;;
		('innoextract')
			archive_extraction_using_innoextract "$archive" "$destination_directory"
		;;
		('lha')
			archive_extraction_using_lha "$archive" "$destination_directory"
		;;
		('msiextract')
			archive_extraction_using_msiextract "$archive" "$destination_directory"
		;;
		('tar')
			archive_extraction_using_tar "$archive" "$destination_directory"
		;;
		('unar')
			archive_extraction_using_unar "$archive" "$destination_directory"
		;;
		('unshield')
			archive_extraction_using_unshield "$archive" "$destination_directory"
		;;
		('unzip')
			archive_extraction_using_unzip "$archive" "$destination_directory"
		;;
		(*)
			error_archive_extractor_invalid "$archive_extractor"
			return 1
		;;
	esac
}

# extract data from the target archive, guessing the extractor from the given type
# USAGE: archive_extraction_from_type $archive $destination_directory
archive_extraction_from_type() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_type
	archive_type=$(archive_get_type "$archive")
	case "$archive_type" in
		('7z')
			archive_extraction_7z "$archive" "$destination_directory"
		;;
		('cabinet')
			archive_extraction_cabinet "$archive" "$destination_directory"
		;;
		('debian')
			archive_extraction_debian "$archive" "$destination_directory"
		;;
		('innosetup')
			archive_extraction_innosetup "$archive" "$destination_directory"
		;;
		('innosetup_nolowercase')
			warning_archive_type_deprecated "$archive"
			export ${archive}_EXTRACTOR_OPTIONS='--progress=1 --silent'
			archive_extraction_innosetup "$archive" "$destination_directory"
		;;
		('installshield')
			archive_extraction_installshield "$archive" "$destination_directory"
		;;
		('iso')
			archive_extraction_iso "$archive" "$destination_directory"
		;;
		('lha')
			archive_extraction_lha "$archive" "$destination_directory"
		;;
		('makeself')
			archive_extraction_makeself "$archive" "$destination_directory"
		;;
		('mojosetup')
			archive_extraction_mojosetup "$archive" "$destination_directory"
		;;
		('mojosetup_unzip')
			warning_archive_type_deprecated "$archive"
			archive_extraction_mojosetup "$archive" "$destination_directory"
		;;
		('msi')
			archive_extraction_msi "$archive" "$destination_directory"
		;;
		('nullsoft-installer')
			archive_extraction_nullsoft "$archive" "$destination_directory"
		;;
		('rar')
			archive_extraction_rar "$archive" "$destination_directory"
		;;
		('tar'|'tar.bz2'|'tar.gz'|'tar.xz')
			archive_extraction_tar "$archive" "$destination_directory"
		;;
		('zip')
			archive_extraction_zip "$archive" "$destination_directory"
		;;
		('zip_unclean')
			warning_archive_type_deprecated "$archive"
			archive_extraction_zip_unclean "$archive" "$destination_directory"
		;;
		(*)
			error_archive_type_invalid "$archive_extractor"
			return 1
		;;
	esac
}
