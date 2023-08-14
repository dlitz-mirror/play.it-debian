#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
}

test_archive_extraction_log_path() {
	local PLAYIT_WORKDIR log_path

	PLAYIT_WORKDIR='/some/temp/dir'
	log_path=$(archive_extraction_log_path)
	assertEquals '/some/temp/dir/logs/archive-extraction.log' "$log_path"
}
