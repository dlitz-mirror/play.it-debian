#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set required variables
	target_version='2.25'
}

setUp() {
	# Set a temporary directory to mess with real files
	TEST_TEMP_DIR=$(mktemp --directory)
	export TEST_TEMP_DIR
}

tearDown() {
	rm --force --recursive "$TEST_TEMP_DIR"
}

test_options_init_default() {
	local option_prefix
	options_init_default
	option_prefix=$(option_value 'prefix')
	assertEquals '/usr' "$option_prefix"
}

test_option_variable() {
	local option_variable
	option_variable=$(option_variable 'free-space-check')
	assertEquals 'PLAYIT_OPTION_FREE_SPACE_CHECK' "$option_variable"
}

test_option_variable_default() {
	local option_variable
	option_variable=$(option_variable_default 'free-space-check')
	assertEquals 'PLAYIT_DEFAULT_OPTION_FREE_SPACE_CHECK' "$option_variable"
}

test_option_update() {
	local option_value target_version
	option_update 'prefix' '/usr/local'
	option_value=$(option_value 'prefix')
	assertEquals '/usr/local' "$option_value"

	# Check that legacy variables are set when targeting ./play.it ≤ 2.22
	target_version='2.22'
	option_update 'prefix' '/usr/local'
	assertEquals '/usr/local' "$OPTION_PREFIX"
}

test_option_update_default() {
	local option_value target_version
	option_update_default 'prefix' '/usr/local'
	option_value=$(option_value 'prefix')
	assertEquals '/usr/local' "$option_value"
}

test_option_value() {
	local option_value
	option_update 'prefix' '/usr/local'
	option_value=$(option_value 'prefix')
	assertEquals '/usr/local' "$option_value"
}

test_option_validity_check() {
	options_init_default

	# Create paths expected to be existing and writable
	option_update 'tmpdir' "${TEST_TEMP_DIR}/tmpdir"
	option_update 'output-dir' "${TEST_TEMP_DIR}output-dir"
	mkdir "${TEST_TEMP_DIR}/tmpdir" "${TEST_TEMP_DIR}output-dir"

	option_update 'checksum' 'none'
	assertTrue 'options_validity_check'
	option_update 'checksum' 'invalid'
	assertFalse 'options_validity_check'
}

test_options_compatibility_check() {
	option_update 'package' 'arch'
	option_update 'compression' 'size'
	assertTrue 'options_compatibility_check'
	option_update 'compression' 'auto'
	assertFalse 'options_compatibility_check'
}
