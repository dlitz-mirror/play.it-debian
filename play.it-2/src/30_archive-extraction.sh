# extract data from given archive
# USAGE: extract_data_from $archive[…]
# NEEDED_VARS: (ARCHIVE) (ARCHIVE_PASSWD) (ARCHIVE_TYPE) (LANG) (PLAYIT_WORKDIR)
# CALLS: liberror extract_7z extract_data_from_print
extract_data_from() {
	[ "$PLAYIT_WORKDIR" ] || return 1
	[ "$ARCHIVE" ] || return 1
	local file
	for file in "$@"; do
		extract_data_from_print "$(basename "$file")"

		local destination
		destination="$PLAYIT_WORKDIR/gamedata"
		mkdir --parents "$destination"
		if [ "$DRY_RUN" -eq 1 ]; then
			printf '\n'
			return 0
		fi
		local archive_type
		archive_type="$(get_value "${ARCHIVE}_TYPE")"
		case "$archive_type" in
			('7z')
				archive_extraction_7z "$file" "$destination"
			;;
			('cabinet')
				cabextract -L -d "$destination" -q "$file"
			;;
			('debian')
				dpkg-deb --extract "$file" "$destination"
			;;
			('innosetup'*)
				archive_extraction_innosetup "$archive_type" "$file" "$destination"
			;;
			('lha')
				archive_extraction_lha "$file" "$destination"
			;;
			('msi')
				msiextract --directory "$destination" "$file" 1>/dev/null 2>&1
				tolower "$destination"
			;;
			('mojosetup'|'iso')
				bsdtar --directory "$destination" --extract --file "$file"
				set_standard_permissions "$destination"
			;;
			('nix_stage1')
				local header_length
				local input_blocksize
				header_length="$(grep --text 'offset=.*head.*wc' "$file" | awk '{print $3}' | head --lines=1)"
				input_blocksize=$(head --lines="$header_length" "$file" | wc --bytes | tr --delete ' ')
				dd if="$file" ibs=$input_blocksize skip=1 obs=1024 conv=sync 2>/dev/null | gunzip --stdout | tar --extract --file - --directory "$destination"
			;;
			('nix_stage2')
				tar --extract --xz --file "$file" --directory "$destination"
			;;
			('rar'|'nullsoft-installer')
				# compute archive password from GOG id
				if [ -z "$ARCHIVE_PASSWD" ] && [ -n "$(get_value "${ARCHIVE}_GOGID")" ]; then
					ARCHIVE_PASSWD="$(printf '%s' "$(get_value "${ARCHIVE}_GOGID")" | md5sum | cut -d' ' -f1)"
				fi
				if [ -n "$ARCHIVE_PASSWD" ]; then
					UNAR_OPTIONS="-password $ARCHIVE_PASSWD"
				fi
				unar -no-directory -output-directory "$destination" $UNAR_OPTIONS "$file" 1>/dev/null
			;;
			('tar'|'tar.gz')
				tar --extract --file "$file" --directory "$destination"
			;;
			('zip')
				unzip -d "$destination" "$file" 1>/dev/null
			;;
			('zip_unclean'|'mojosetup_unzip')
				set +o errexit
				unzip -d "$destination" "$file" 1>/dev/null 2>&1
				set -o errexit
				set_standard_permissions "$destination"
			;;
			(*)
				liberror 'ARCHIVE_TYPE' 'extract_data_from'
			;;
		esac

		if [ "${archive_type#innosetup}" = "$archive_type" ]; then
			print_ok
		fi
	done
}

# print data extraction message
# USAGE: extract_data_from_print $file
# NEEDED VARS: (LANG)
# CALLED BY: extract_data_from
extract_data_from_print() {
	case "${LANG%_*}" in
		('fr')
			string='Extraction des données de %s'
		;;
		('en'|*)
			string='Extracting data from %s'
		;;
	esac
	printf "$string" "$1"
}

# extract data from 7z archive
# USAGE: archive_extraction_7z $archive $destination
# CALLS: error_archive_extraction_7z_no_extractor_found
# CALLED BY: extract_data_from
archive_extraction_7z() {
	local file destination
	file="$1"
	destination="$2"
	if command -v 7zr >/dev/null 2>&1; then
		7zr x -o"$destination" -y "$file" 1>/dev/null
	elif command -v 7za >/dev/null 2>&1; then
		7za x -o"$destination" -y "$file" 1>/dev/null
	elif command -v unar >/dev/null 2>&1; then
		unar -output-directory "$destination" -force-overwrite -no-directory "$file" 1>/dev/null
	else
		error_archive_no_extractor_found '7z'
	fi
}

# extract data from LHA archive
# USAGE: archive_extraction_lha $archive $destination
# CALLS: error_archive_no_extractor_found
# CALLED BY: extract_data_from
archive_extraction_lha() {
	local file destination
	file="$1"
	destination="$2"
	if command -v lha >/dev/null 2>&1; then
		lha -ew="$destination" "$file" >/dev/null
		set_standard_permissions "$destination"
	elif command -v bsdtar >/dev/null 2>&1; then
		bsdtar --directory "$destination" --extract --file "$file"
		set_standard_permissions "$destination"
	else
		error_archive_no_extractor_found 'lha'
	fi
}

# extract data from InnoSetup archive
# USAGE: archive_extraction_innosetup $archive_type $archive $destination
# CALLS: archive_extraction_innosetup_error_version
archive_extraction_innosetup() {
	local archive
	local archive_type
	local destination
	local options
	archive_type="$1"
	archive="$2"
	destination="$3"
	options='--progress=1 --silent'
	if [ -n "${archive_type%%*_nolowercase}" ]; then
		options="$options --lowercase"
	fi
	if ( innoextract --list --silent "$archive" 2>&1 1>/dev/null |\
		head --lines=1 |\
		grep --ignore-case 'unexpected setup data version' 1>/dev/null )
	then
		archive_extraction_innosetup_error_version "$archive"
	fi
	printf '\n'
	innoextract $options --extract --output-dir "$destination" "$file" 2>/dev/null
}

