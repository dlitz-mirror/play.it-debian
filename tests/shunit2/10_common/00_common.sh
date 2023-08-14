#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set some default option values
	export PLAYIT_OPTION_DEBUG=0
}

setUp() {
	# Set a temporary directory to mess with real files
	TEST_TEMP_DIR=$(mktemp --directory)
	export TEST_TEMP_DIR
}

tearDown() {
	rm --force --recursive "$TEST_TEMP_DIR"
}

test_set_standard_permissions() {
	# Create a file and a directory with inappropriate permissions
	local test_directory test_file
	test_directory="${TEST_TEMP_DIR}/test_directory"
	test_file="${TEST_TEMP_DIR}/test_file"
	mkdir --parents "$test_directory"
	touch "$test_file"
	chmod 777 "$test_directory" "$test_file"

	# Enforce standard permissions
	set_standard_permissions "$TEST_TEMP_DIR"

	# Check the permissions
	local test_directory_permissions test_file_permissions
	test_directory_permissions=$(stat --printf='%a' "$test_directory")
	test_file_permissions=$(stat --printf='%a' "$test_file")
	assertEquals 755 "$test_directory_permissions"
	assertEquals 644 "$test_file_permissions"
}

_test_tolower_generic() {
	local tolower_command
	tolower_command="$1"

	# Create a file and a directory using mixed case
	local test_directory test_file
	test_directory="${TEST_TEMP_DIR}/Test_Directory"
	test_file="${test_directory}/Test_File"
	mkdir --parents "$test_directory"
	touch "$test_file"

	# Convert all paths to lowercase
	$tolower_command "$TEST_TEMP_DIR"

	# Check that the paths have been converted
	assertTrue "test -f '${TEST_TEMP_DIR}/test_directory/test_file'"
	assertFalse "test -f '${TEST_TEMP_DIR}/Test_Directory/Test_File'"
}

test_tolower() {
	_test_tolower_generic 'tolower'
}

test_tolower_convmv() {
	_test_tolower_generic 'tolower_convmv'
}

test_tolower_shell() {
	_test_tolower_generic 'tolower_shell'
}

_test_toupper_generic() {
	local toupper_command
	toupper_command="$1"

	# Create a file and a directory using mixed case
	local test_directory test_file
	test_directory="${TEST_TEMP_DIR}/Test_Directory"
	test_file="${test_directory}/Test_File"
	mkdir --parents "$test_directory"
	touch "$test_file"

	# Convert all paths to uppercase
	$toupper_command "$TEST_TEMP_DIR"

	# Check that the paths have been converted
	assertTrue "test -f '${TEST_TEMP_DIR}/TEST_DIRECTORY/TEST_FILE'"
	assertFalse "test -f '${TEST_TEMP_DIR}/Test_Directory/Test_File'"
}

test_toupper() {
	_test_toupper_generic 'toupper'
}

test_toupper_convmv() {
	_test_toupper_generic 'toupper_convmv'
}

test_toupper_shell() {
	_test_toupper_generic 'toupper_shell'
}

test_file_type() {
	local file_type
	file_type=$(file_type 'play.it')
	assertEquals 'text/x-shellscript' "$file_type"
}
