# extract data from given archive
# USAGE: extract_data_from $archive[…]
# NEEDED_VARS: (ARCHIVE) (ARCHIVE_PASSWD) (ARCHIVE_TYPE) (LANG) (PLAYIT_WORKDIR)
# CALLS: extract_7z
extract_data_from() {
	[ "$PLAYIT_WORKDIR" ] || return 1
	[ "$ARCHIVE" ] || return 1
	local file
	for file in "$@"; do
		information_archive_data_extraction "$(basename "$file")"

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
				archive_extract_with_unzip "$file" "$destination"
			;;
			('zip_unclean'|'mojosetup_unzip')
				local exitcode
				exitcode=0
				# 2>/dev/null removes output from unzip -l about errors in the file
				archive_extract_with_unzip "$file" "$destination" 2>/dev/null || exitcode=$?
				case $exitcode in
					(0|1|2)
						# Extraction is a success, keep going
					;;
					(*)
						return $exitcode
					;;
				esac
				set_standard_permissions "$destination"
			;;
			(*)
				error_invalid_argument 'ARCHIVE_TYPE' 'extract_data_from'
			;;
		esac

		if [ "${archive_type#innosetup}" = "$archive_type" ]; then
			print_ok
		fi
	done
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
		error_innoextract_version_too_old "$archive"
	fi
	printf '\n'
	innoextract $options --extract --output-dir "$destination" "$file" 2>/dev/null
}

# extract data using unzip
# USAGE: archive_extract_with_unzip $archive $destination
archive_extract_with_unzip() {
	local archive
	local destination
	local files_list
	archive="$1"
	destination="$2"
	files_list="$(archive_get_files_to_extract "$archive" | sed --regexp-extended 'p;/^.+$/s|$|/*|')"
	local status=0
	set -o noglob
	unzip -l "$archive" $files_list >/dev/null || status="$?" # Make sure at least one glob matches
	[ "$status" -eq 11 ] && return "$status"
	set +o errexit
	# shellcheck disable=SC2046
	(
		IFS='
'
		unzip -d "$destination" "$archive" $files_list 1>/dev/null 2>/dev/null # 2>/dev/null removes output about missing globs
	)
	local status="$?"
	set -o errexit
	set +o noglob
	[ "$status" -eq 0 ] || [ "$status" -eq 11 ] || return "$status" # 11 is when at least one glob didn't watch when not using -l
}

# Outputs all files that need to be extracted
# USAGE: archive_get_files_to_extract
# CALLS: archive_concat_needed_files_with_path
archive_get_files_to_extract() {
	# All files should be extracted for scripts targeting library version < 2.12
	if version_target_is_older_than '2.12'; then
		return 0
	fi

	for package in $PACKAGES_LIST; do
		PKG="${package#PKG_}"
		archive_concat_needed_files_with_path "GAME_$PKG" "DOC_$PKG"
		for i in $(seq 0 9); do
			archive_concat_needed_files_with_path "GAME${i}_$PKG" "DOC${i}_$PKG"
		done
	done
	# awk '!x[$0]++' removes duplicate lines, but without sorting (unlike sort --unique, which needs to wait for all the input first)
	grep --fixed-strings 'icons_get_from_workdir' "$0" | grep --extended-regexp --only-matching 'APP_[_0-9A-Z]+' | awk '!x[$0]++' | while read -r app; do
		use_archive_specific_value "${app}_ICONS_LIST"
		local icons_list
		icons_list="$(get_value "${app}_ICONS_LIST")"
		[ -n "$icons_list" ] || icons_list="${app}_ICON"
		for icon in $icons_list; do
			use_archive_specific_value "$icon"
			printf '%s\n' "$(get_value "$icon" | sed 's/[][\\?*]/\\&/g' | tr '\n' '?')" # Print glob escaped version
		done
	done
	# shellcheck disable=2086
	printf '%s\n' $EXTRA_ARCHIVE_FILES
}

# Adds path prefix for files in ARCHIVE_*_FILES
# USAGE: archive_concat_needed_files_with_path $specifier …
# CALLED BY: archive_get_files_to_extract
archive_concat_needed_files_with_path() {
	for specifier in "$@"; do
		use_archive_specific_value "ARCHIVE_${specifier}_FILES"
		use_archive_specific_value "ARCHIVE_${specifier}_PATH"
		set -o noglob
		for file in $(get_value "ARCHIVE_${specifier}_FILES"); do
			if [ "$(get_value "ARCHIVE_${specifier}_PATH")" != '.' ]; then
				printf '%s\n' "$(get_value "ARCHIVE_${specifier}_PATH" | sed 's/[][\\?*]/\\&/g' | tr '\n' '?')/$file" # Print glob escaped version of the path with the file
			else
				printf '%s\n' "$file"
			fi
		done
		set +o noglob
	done
}

