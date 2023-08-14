#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
}

test_application_type() {
	local APP_MAIN_TYPE APP_MAIN_SCUMMID application_type

	APP_MAIN_SCUMMID='engine:game'
	application_type=$(application_type 'APP_MAIN')
	assertEquals 'scummvm' "$application_type"

	APP_MAIN_TYPE='native'
	application_type=$(application_type 'APP_MAIN')
	assertEquals 'native' "$application_type"

	# Test that invalid types are rejected
	APP_MAIN_TYPE='invalid'
	assertFalse "application_type 'APP_MAIN'"
}

test_application_type_variant() {
	local APP_MAIN_TYPE_VARIANT UNITY3D_NAME UNREALENGINE4_NAME application_type_variant

	UNITY3D_NAME='SomeName'
	application_type_variant=$(application_type_variant 'APP_MAIN')
	assertEquals 'unity3d' "$application_type_variant"

	UNREALENGINE4_NAME='SomeName'
	application_type_variant=$(application_type_variant 'APP_MAIN')
	assertEquals 'unrealengine4' "$application_type_variant"

	APP_MAIN_TYPE_VARIANT='some-other-variant'
	application_type_variant=$(application_type_variant 'APP_MAIN')
	assertEquals 'some-other-variant' "$application_type_variant"
}
