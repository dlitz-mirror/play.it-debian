# check the presence of required tools to handle given archive
# USAGE: archive_dependencies_check $archive
archive_dependencies_check() {
	local archive
	archive="$1"

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
		('innosetup1.7'|'innosetup_nolowercase')
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
		('msi')
			archive_dependencies_check_type_msi
		;;
		('mojosetup')
			archive_dependencies_check_type_mojosetup
		;;
		('mojosetup_unzip')
			archive_dependencies_check_type_mojosetup_unzip
		;;
		('nix_stage1')
			archive_dependencies_check_type_nixstaller_stage1
		;;
		('nix_stage2')
			archive_dependencies_check_type_nixstaller_stage2
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
		('innosetup1.7'|'innosetup_nolowercase')
			###
			# TODO
			# Usage of "innosetup1.7" or "innosetup_nolowercase" archive types should trigger a deprecation warning.
			###
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
		('msi')
			archive_extraction_msi "$archive" "$destination_directory"
		;;
		('mojosetup')
			archive_extraction_mojosetup "$archive" "$destination_directory"
		;;
		('mojosetup_unzip')
			###
			# TODO
			# Usage of "mojosetup_unzip" archive type should trigger a deprecation warning.
			###
			archive_extraction_mojosetup_unzip "$archive" "$destination_directory"
		;;
		('nix_stage1')
			archive_extraction_nixstaller_stage1 "$archive" "$destination_directory"
		;;
		('nix_stage2')
			archive_extraction_nixstaller_stage2 "$archive" "$destination_directory"
		;;
		('nullsoft-installer')
			archive_extraction_nullsoft "$archive" "$destination_directory"
		;;
		('rar')
			archive_extraction_rar "$archive" "$destination_directory"
		;;
		('tar'|'tar.gz'|'tar.xz')
			archive_extraction_tar "$archive" "$destination_directory"
		;;
		('zip')
			archive_extraction_zip "$archive" "$destination_directory"
		;;
		('zip_unclean')
			###
			# TODO
			# Usage of "zip_unclean" archive type should trigger a deprecation warning.
			###
			archive_extraction_zip_unclean "$archive" "$destination_directory"
		;;
		(*)
			error_invalid_argument "${archive}_TYPE" 'archive_extraction'
			return 1
		;;
	esac

	information_archive_data_extraction_done
}

