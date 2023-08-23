#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set required variables
	target_version='2.25'
}

test_content_path_default() {
	local ARCHIVE CONTENT_PATH_DEFAULT CONTENT_PATH_DEFAULT_0 content_path_default

	CONTENT_PATH_DEFAULT='some/path'
	content_path_default=$(content_path_default)
	assertEquals 'some/path' "$content_path_default"

	ARCHIVE='ARCHIVE_BASE_0'
	CONTENT_PATH_DEFAULT_0='some/other/path'
	content_path_default=$(content_path_default)
	assertEquals 'some/other/path' "$content_path_default"

	unset CONTENT_PATH_DEFAULT_0 CONTENT_PATH_DEFAULT
	content_path_default=$(content_path_default)
	assertNull "$content_path_default"
}

test_content_path() {
	local \
		ARCHIVE CONTENT_PATH_DEFAULT target_version \
		CONTENT_GAME_DATA_PATH CONTENT_GAME_DATA_PATH_0 \
		ARCHIVE_GAME_DATA_PATH ARCHIVE_GAME_DATA_PATH_MAIN \
		content_path

	CONTENT_PATH_DEFAULT='default/path'
	content_path=$(content_path 'GAME_DATA')
	assertEquals 'default/path' "$content_path"

	CONTENT_GAME_DATA_PATH='specific/path'
	content_path=$(content_path 'GAME_DATA')
	assertEquals 'specific/path' "$content_path"

	ARCHIVE='ARCHIVE_BASE_0'
	CONTENT_GAME_DATA_PATH_0='more/specific/path'
	content_path=$(content_path 'GAME_DATA')
	assertEquals 'more/specific/path' "$content_path"
	unset ARCHIVE

	# Test the behaviour of game scripts targeting ./play.it < 2.19

	unset CONTENT_GAME_DATA_PATH
	target_version='2.18'
	content_path=$(content_path 'GAME_DATA')
	assertEquals 'default/path' "$content_path"

	ARCHIVE_GAME_DATA_PATH='old/path'
	content_path=$(content_path 'GAME_DATA')
	assertEquals 'old/path' "$content_path"

	## Old archive naming scheme must be used here,
	## because we target ./play.it < 2.21
	ARCHIVE='ARCHIVE_MAIN'
	ARCHIVE_GAME_DATA_PATH_MAIN='other/old/path'
	content_path=$(content_path 'GAME_DATA')
	assertEquals 'other/old/path' "$content_path"
}

test_content_files() {
	local \
		ARCHIVE target_version \
		CONTENT_GAME_DATA_FILES CONTENT_GAME_DATA_FILES_0 \
		ARCHIVE_GAME_DATA_FILES ARCHIVE_GAME_DATA_FILES_MAIN \
		content_files_expected content_files

	content_files=$(content_files 'GAME_DATA')
	assertNull "$content_files"

	CONTENT_GAME_DATA_FILES='some
list
of
files'
	content_files=$(content_files 'GAME_DATA')
	content_files_expected='some
list
of
files'
	assertEquals "$content_files_expected" "$content_files"

	ARCHIVE='ARCHIVE_BASE_0'
	CONTENT_GAME_DATA_FILES_0='specific
list
of
files'
	content_files=$(content_files 'GAME_DATA')
	content_files_expected='specific
list
of
files'
	assertEquals "$content_files_expected" "$content_files"
	unset ARCHIVE

	# Test the behaviour of game scripts targeting ./play.it < 2.19

	unset CONTENT_GAME_DATA_FILES
	target_version='2.18'
	content_files=$(content_files 'GAME_DATA')
	assertNull "$content_files"

	ARCHIVE_GAME_DATA_FILES='old
list
of
files'
	content_files=$(content_files 'GAME_DATA')
	content_files_expected='old
list
of
files'
	assertEquals "$content_files_expected" "$content_files"

	## Old archive naming scheme must be used here,
	## because we target ./play.it < 2.21
	ARCHIVE='ARCHIVE_MAIN'
	ARCHIVE_GAME_DATA_FILES_MAIN='other
old
list
of
files'
	content_files=$(content_files 'GAME_DATA')
	content_files_expected='other
old
list
of
files'
	assertEquals "$content_files_expected" "$content_files"

	# Fallback lists of files for Unity3D and Unreal Engine 4 games are not tested here.
}
