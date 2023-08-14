#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set some default option values
	PLAYIT_OPTION_TMPDIR=$(mktemp --directory --dry-run)
	PLAYIT_OPTION_FREE_SPACE_CHECK=0
	export PLAYIT_OPTION_TMPDIR PLAYIT_OPTION_FREE_SPACE_CHECK
}

setUp() {
	mkdir --parents "$PLAYIT_OPTION_TMPDIR"
}

tearDown() {
	rm --force --recursive "$PLAYIT_OPTION_TMPDIR"
}

test_set_temp_directories() {
	local GAME_ID PLAYIT_WORKDIR PKG_MAIN_PATH
	GAME_ID='some-game'

	set_temp_directories

	assertTrue "test -n '$PLAYIT_WORKDIR'"
	assertTrue "test -d '$PLAYIT_WORKDIR'"

	# Check that the legacy PKG_xxx_PATH variables are set
	assertTrue "test -n '$PKG_MAIN_PATH'"
}

test_temporary_directory_path() {
	local temporary_directory_path
	temporary_directory_path=$(temporary_directory_path)

	assertEquals "$PLAYIT_OPTION_TMPDIR" "$temporary_directory_path"
}
