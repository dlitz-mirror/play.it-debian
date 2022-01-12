# extract the content of a Debian package (.deb)
# USAGE: archive_extraction_debian $archive $destination_directory
archive_extraction_debian() {
	local archive destination_directory
	archive="$1"
	destination_directory="$2"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	if command -v 'dpkg-deb' >/dev/null 2>&1; then
		debug_external_command "dpkg-deb --extract \"$archive_path\" \"$destination_directory\""
		dpkg-deb --extract "$archive_path" "$destination_directory"
	elif command -v 'bsdtar' >/dev/null 2>&1; then
		debug_external_command "bsdtar --extract --to-stdout --file \"$archive_path\" 'data*' | bsdtar --directory \"$destination_directory\" --extract --file /dev/stdin"
		bsdtar --extract --to-stdout --file "$archive_path" 'data*' | \
			bsdtar --directory "$destination_directory" --extract --file /dev/stdin
	elif command -v 'unar' >/dev/null 2>&1; then
		local temporary_directory
		temporary_directory="${PLAYIT_WORKDIR}/extraction"
		mkdir --parents "$temporary_directory"
		debug_external_command "unar -force-overwrite -no-directory -output-directory \"$temporary_directory\" \"$archive_path\" 'data*' 1>/dev/null"
		unar -force-overwrite -no-directory -output-directory "$temporary_directory" "$archive_path" 'data*' 1>/dev/null
		debug_external_command "unar -force-overwrite -no-directory -output-directory \"$destination_directory\" \"$temporary_directory\"/data* 1>/dev/null"
		unar -force-overwrite -no-directory -output-directory "$destination_directory" "$temporary_directory"/data* 1>/dev/null
		rm --recursive --force "$temporary_directory"
	elif command -v 'tar' >/dev/null 2>&1 && command -v '7z' >/dev/null 2>&1; then
		debug_external_command "7z x -i'!data*' -so \"$archive_path\" | tar --directory \"$destination_directory\" --extract"
		7z x -i'!data*' -so "$archive_path" | \
			tar --directory "$destination_directory" --extract
	elif command -v 'tar' >/dev/null 2>&1 && command -v '7zr' >/dev/null 2>&1; then
		debug_external_command "7zr x -so \"$archive_path\" | tar --directory \"$destination_directory\" --extract"
		7zr x -so "$archive_path" | \
			tar --directory "$destination_directory" --extract
	elif command -v 'tar' >/dev/null 2>&1 && command -v 'ar' >/dev/null 2>&1; then
		local temporary_directory
		temporary_directory="${PLAYIT_WORKDIR}/extraction"
		mkdir --parents "$temporary_directory"
		local archive_path
		archive_path=$(realpath --canonicalize-existing "$archive_path")
		(
			cd "$temporary_directory"
			debug_external_command "ar x \"$archive_path\" \"$(ar t \"$archive_path\" | grep ^data)\""
			ar x "$archive_path" "$(ar t "$archive_path" | grep ^data)"
		)
		debug_external_command "tar --extract --directory \"$destination_directory\" --file \"$temporary_directory\"/data*"
		tar --extract --directory "$destination_directory" --file "$temporary_directory"/data*
		rm --recursive --force "$temporary_directory"
	else
		error_archive_no_extractor_found 'debian'
		return 1
	fi
}

