#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
}

test_get_value() {
	local SOME_VARIABLE variable_value
	SOME_VARIABLE='some value'
	variable_value=$(get_value 'SOME_VARIABLE')
	assertEquals 'some value' "$variable_value"
}

test_variable_is_empty() {
	local SOME_VARIABLE
	assertTrue 'variable_is_empty SOME_VARIABLE'
	SOME_VARIABLE='some value'
	assertFalse 'variable_is_empty SOME_VARIABLE'
}
