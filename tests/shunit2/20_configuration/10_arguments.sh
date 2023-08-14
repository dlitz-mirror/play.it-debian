#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
}

setUp() {
	# Set a temporary directory to mess with real files
	TEST_TEMP_DIR=$(mktemp --directory)
	export TEST_TEMP_DIR
}

tearDown() {
	rm --force --recursive "$TEST_TEMP_DIR"
}

test_parse_arguments() {
	local SOURCE_ARCHIVE option_overwrite option_free_space_check option_prefix
	touch "${TEST_TEMP_DIR}/some_game_archive.tar.gz"
	parse_arguments --overwrite --no-free-space-check --prefix /usr/local "${TEST_TEMP_DIR}/some_game_archive.tar.gz"

	option_overwrite=$(option_value 'overwrite')
	assertEquals 1 "$option_overwrite"
	option_free_space_check=$(option_value 'free-space-check')
	assertEquals 0 "$option_free_space_check"
	option_prefix=$(option_value 'prefix')
	assertEquals '/usr/local' "$option_prefix"
	assertEquals "${TEST_TEMP_DIR}/some_game_archive.tar.gz" "$SOURCE_ARCHIVE"
}

test_parse_arguments_default() {
	local option_overwrite option_free_space_check option_tmpdir
	parse_arguments_default --overwrite --no-free-space-check --tmpdir /var/tmp/play.it

	option_overwrite=$(option_value 'overwrite')
	assertEquals 1 "$option_overwrite"
	option_free_space_check=$(option_value 'free-space-check')
	assertEquals 0 "$option_free_space_check"
	option_tmpdir=$(option_value 'tmpdir')
	assertEquals '/var/tmp/play.it' "$option_tmpdir"
}
