# Print the path to the log file for archive data extraction
# USAGE: archive_extraction_log_path
# RETURN: the absolute path to the log file,
#         the file might not exist yet, so the calling function should handle the directories and file creation
archive_extraction_log_path() {
	printf '%s/logs/archive-extraction.log' "$PLAYIT_WORKDIR"
}
