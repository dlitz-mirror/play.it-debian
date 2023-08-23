# List the requirements to extract the contents of a MojoSetup installer
# USAGE: archive_requirements_mojosetup_list
archive_requirements_mojosetup_list() {
	# ShellCheck false-positive
	# Quote this to prevent word splitting.
	# shellcheck disable=SC2046
	printf '%s\n' \
		$(archive_requirements_makeself_list) \
		'unzip'
}

# Check the presence of required tools to handle a MojoSetup installer
# USAGE: archive_requirements_mojosetup_check
archive_requirements_mojosetup_check() {
	local commands_list required_command
	commands_list=$(archive_requirements_mojosetup_list)
	for required_command in $commands_list; do
		if ! command -v "$required_command" >/dev/null 2>&1; then
			error_dependency_not_found "$required_command"
			return 1
		fi
	done
}

# Extract the content of a MojoSetup installer
# USAGE: archive_extraction_mojosetup $archive $destination_directory $log_file
archive_extraction_mojosetup() {
	local archive destination_directory log_file
	archive="$1"
	destination_directory="$2"
	log_file="$3"

	local archive_path
	archive_path=$(archive_find_path "$archive")

	# Fetch the archive properties
	local archive_makeself_offset archive_mojosetup_filesize archive_offset
	archive_makeself_offset=$(makeself_offset "$archive_path")
	archive_mojosetup_filesize=$(makeself_filesize "$archive_path")
	archive_offset=$((archive_makeself_offset + archive_mojosetup_filesize))
	## Arbitrary value, small values would increase the time spent on the dd calls.
	archive_block_size=4096

	# Extract the .zip archive containing the game data
	local archive_game_data archive_extraction_return_code
	archive_game_data="${destination_directory}/mojosetup-game-data.zip"
	## Silence ShellCheck false-positive
	## Consider using { cmd1; cmd2; } >> file instead of individual redirects.
	# shellcheck disable=SC2129
	printf 'dd if="%s" ibs="%s" obs="%s" skip="%sB" > "%s"\n' "$archive_path" "$archive_block_size" "$archive_block_size" "$archive_offset" "$archive_game_data" >> "$log_file"
	{
		dd if="$archive_path" ibs="$archive_block_size" obs="$archive_block_size" skip="${archive_offset}B" > "$archive_game_data" 2>> "$log_file"
		archive_extraction_return_code=$?
	} || true
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi

	# Extract the game data
	local archive_extraction_return_code
	printf 'unzip -d "%s" "%s"\n' "$destination_directory" "$archive_game_data" >> "$log_file"
	{
		unzip -d "$destination_directory" "$archive_game_data" >> "$log_file" 2>&1
		archive_extraction_return_code=$?
	} || true
	if [ $archive_extraction_return_code -ne 0 ]; then
		error_archive_extraction_failure "$archive"
		return 1
	fi
	rm "$archive_game_data"
}

