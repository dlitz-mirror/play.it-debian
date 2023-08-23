#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set some required options
	target_version='2.25'
}

test_archive_find_path() {
	local ARCHIVE_BASE_0 archive_path

	# Bypass the search for the archive path
	archive_find_path_from_name() {
		printf '/some/fake/path/%s' "$1"
	}

	ARCHIVE_BASE_0='some_game_archive.tar.gz'
	archive_path=$(archive_find_path 'ARCHIVE_BASE_0')
	assertEquals '/some/fake/path/some_game_archive.tar.gz' "$archive_path"
}

test_archive_set_properties_from_candidate() {
	local \
		ARCHIVE_BASE_0 ARCHIVE_BASE_0_PART1 ARCHIVE_BASE_0_EXTRACTOR ARCHIVE_BASE_0_EXTRACTOR_OPTIONS ARCHIVE_BASE_0_MD5 ARCHIVE_BASE_0_TYPE ARCHIVE_BASE_0_SIZE ARCHIVE_BASE_0_VERSION \
		SOURCE_ARCHIVE SOURCE_ARCHIVE_PART1 SOURCE_ARCHIVE_EXTRACTOR SOURCE_ARCHIVE_EXTRACTOR_OPTIONS SOURCE_ARCHIVE_MD5 SOURCE_ARCHIVE_TYPE SOURCE_ARCHIVE_SIZE SOURCE_ARCHIVE_VERSION \
		archive_path

	# Bypass the search for the archive path
	archive_find_path_from_name() {
		printf '/some/fake/path/%s' "$1"
	}

	ARCHIVE_BASE_0='setup_some_game.exe'
	ARCHIVE_BASE_0_PART1='setup_some_game-1.bin'
	ARCHIVE_BASE_0_EXTRACTOR='innoextract'
	ARCHIVE_BASE_0_EXTRACTOR_OPTIONS='--gog'
	ARCHIVE_BASE_0_MD5='6c9bd7e1cf88fdbfa0e75f694bf8b0e5'
	ARCHIVE_BASE_0_TYPE='innosetup'
	ARCHIVE_BASE_0_SIZE='42000'
	ARCHIVE_BASE_0_VERSION='1.42'
	archive_set_properties_from_candidate 'SOURCE_ARCHIVE' 'ARCHIVE_BASE_0' >/dev/null
	assertEquals '/some/fake/path/setup_some_game.exe' "$SOURCE_ARCHIVE"
	assertEquals 'setup_some_game-1.bin' "$SOURCE_ARCHIVE_PART1"
	assertEquals 'innoextract' "$SOURCE_ARCHIVE_EXTRACTOR"
	assertEquals '--gog' "$SOURCE_ARCHIVE_EXTRACTOR_OPTIONS"
	assertEquals '6c9bd7e1cf88fdbfa0e75f694bf8b0e5' "$SOURCE_ARCHIVE_MD5"
	assertEquals 'innosetup' "$SOURCE_ARCHIVE_TYPE"
	assertEquals '42000' "$SOURCE_ARCHIVE_SIZE"
	assertEquals '1.42' "$SOURCE_ARCHIVE_VERSION"
}

test_archive_add_size_to_total() {
	local ARCHIVE_SIZE ARCHIVE_BASE_0_SIZE archive_size

	archive_add_size_to_total 'ARCHIVE_BASE_0'
	assertEquals 0 "$ARCHIVE_SIZE"

	ARCHIVE_BASE_0_SIZE='42000'
	archive_add_size_to_total 'ARCHIVE_BASE_0'
	assertEquals 42000 "$ARCHIVE_SIZE"

	ARCHIVE_SIZE=100000
	archive_add_size_to_total 'ARCHIVE_BASE_0'
	assertEquals 142000 "$ARCHIVE_SIZE"
}

test_archive_get_type() {
	local ARCHIVE_BASE_0 ARCHIVE_BASE_0_TYPE ARCHIVE_BASE_0_PART1 archive_type

	# Bypass the search for the archive path
	archive_find_path() {
		return 0
	}
	archive_guess_type_from_headers() {
		return 0
	}

	ARCHIVE_BASE_0='some_game_archive.tar.gz'
	archive_type=$(archive_get_type 'ARCHIVE_BASE_0')
	assertEquals 'tar.gz' "$archive_type"

	ARCHIVE_BASE_0_TYPE='zip'
	archive_type=$(archive_get_type 'ARCHIVE_BASE_0')
	assertEquals 'zip' "$archive_type"

	ARCHIVE_BASE_0_PART1='some_strange_game_archive.xyz'
	archive_type=$(archive_get_type 'ARCHIVE_BASE_0_PART1')
	assertEquals 'zip' "$archive_type"

	# Check that an error is thrown if no archive type is set, and none can be guessed.
	ARCHIVE_BASE_0='some_strange_game_archive.xyz'
	unset ARCHIVE_BASE_0_TYPE
	assertFalse "archive_get_type 'ARCHIVE_BASE_0'"
}

test_archive_guess_type_from_name() {
	local archive_type

	archive_type=$(archive_guess_type_from_name 'some_game_archive.tar.gz')
	assertEquals 'tar.gz' "$archive_type"

	archive_type=$(archive_guess_type_from_name 'some_strange_game_archive.xyz')
	assertNull 'archive_guess_type_from_name hallucinated a type for an archive using an unknown extension.' "$archive_type"

	return 0
}

test_archive_extractor() {
	local ARCHIVE_BASE_0_EXTRACTOR archive_extractor

	ARCHIVE_BASE_0_EXTRACTOR='bsdtar'
	archive_extractor=$(archive_extractor 'ARCHIVE_BASE_0')
	assertEquals 'bsdtar' "$archive_extractor"

	archive_extractor=$(archive_extractor 'ARCHIVE_BASE_0_PART1')
	assertEquals 'bsdtar' "$archive_extractor"

	unset ARCHIVE_BASE_0_EXTRACTOR
	archive_extractor=$(archive_extractor 'ARCHIVE_BASE_0')
	assertNull "$archive_extractor"
}

test_archive_extractor_options() {
	local ARCHIVE_BASE_0_EXTRACTOR_OPTIONS archive_extractor_options

	ARCHIVE_BASE_0_EXTRACTOR_OPTIONS='--gog'
	archive_extractor_options=$(archive_extractor_options 'ARCHIVE_BASE_0')
	assertEquals '--gog' "$archive_extractor_options"

	unset ARCHIVE_BASE_0_EXTRACTOR_OPTIONS
	archive_extractor_options=$(archive_extractor_options 'ARCHIVE_BASE_0')
	assertNull "$archive_extractor_options"
}

test_archives_return_list() {
	local ARCHIVE_BASE_0 ARCHIVE_BASE_1 ARCHIVE_MAIN ARCHIVE_MAIN_OLD ARCHIVES_LIST archives_list archives_list_expected

	ARCHIVES_LIST='ARCHIVE_BASE_0 ARCHIVE_BASE_1'
	archives_list=$(archives_return_list)
	assertEquals 'ARCHIVE_BASE_0 ARCHIVE_BASE_1' "$archives_list"

	unset ARCHIVES_LIST
	ARCHIVE_BASE_0='some_game_archive.tar.gz'
	ARCHIVE_BASE_1='some_other_game_archive.tar.gz'
	archives_list_expected='ARCHIVE_BASE_0
ARCHIVE_BASE_1'
	archives_list=$(archives_return_list)
	assertEquals "$archives_list_expected" "$archives_list"

	# Check that archive names using the old format are detected for game scripts targeting ./play.it ≤ 2.20
	unset ARCHIVE_BASE_0 ARCHIVE_BASE_1
	target_version='2.20'
	ARCHIVE_MAIN='some_game_archive.tar.gz'
	ARCHIVE_MAIN_OLD='some_other_game_archive.tar.gz'
	archives_list_expected='ARCHIVE_MAIN
ARCHIVE_MAIN_OLD'
	archives_list=$(archives_return_list)
	assertEquals "$archives_list_expected" "$archives_list"
}
