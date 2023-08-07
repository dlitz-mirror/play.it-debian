#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set some default option values
	export target_version='2.25'
}

test_context_archive() {
	local ARCHIVE context_archive
	context_archive=$(context_archive)
	assertNull "$context_archive"
	ARCHIVE='ARCHIVE_BASE_0'
	context_archive=$(context_archive)
	assertEquals 'ARCHIVE_BASE_0' "$context_archive"
}

test_context_package() {
	local PACKAGES_LIST PKG context_package
	context_package=$(context_package)
	assertEquals 'PKG_MAIN' "$context_package"
	PACKAGES_LIST='PKG_BIN PKG_DATA'
	context_package=$(context_package)
	assertEquals 'PKG_BIN' "$context_package"
	PKG='PKG_BIN32'
	context_package=$(context_package)
	assertEquals 'PKG_BIN32' "$context_package"
}

test_context_archive_suffix() {
	local ARCHIVE target_version context_archive_suffix
	ARCHIVE='ARCHIVE_BASE_MULTIARCH_0'
	context_archive_suffix=$(context_archive_suffix)
	assertEquals '_MULTIARCH_0' "$context_archive_suffix"
	target_version='2.20'
	ARCHIVE='ARCHIVE_OLD0'
	context_archive_suffix=$(context_archive_suffix)
	assertEquals '_OLD0' "$context_archive_suffix"
}

test_context_package_suffix() {
	local PKG context_package_suffix
	PKG='PKG_BIN32'
	context_package_suffix=$(context_package_suffix)
	assertEquals '_BIN32' "$context_package_suffix"
}

test_context_name() {
	local ARCHIVE PKG SOME_VARIABLE SOME_VARIABLE_BIN32 SOME_VARIABLE_MULTIARCH SOME_VARIABLE_MULTIARCH_0 context_name
	ARCHIVE='ARCHIVE_BASE_MULTIARCH_0'
	PKG='PKG_BIN32'
	context_name=$(context_name 'SOME_VARIABLE')
	assertNull "$context_name"
	SOME_VARIABLE='some value'
	context_name=$(context_name 'SOME_VARIABLE')
	assertEquals 'SOME_VARIABLE' "$context_name"
	SOME_VARIABLE_BIN32='some value'
	context_name=$(context_name 'SOME_VARIABLE')
	assertEquals 'SOME_VARIABLE_BIN32' "$context_name"
	SOME_VARIABLE_MULTIARCH='some value'
	context_name=$(context_name 'SOME_VARIABLE')
	assertEquals 'SOME_VARIABLE_MULTIARCH' "$context_name"
	SOME_VARIABLE_MULTIARCH_0='some value'
	context_name=$(context_name 'SOME_VARIABLE')
	assertEquals 'SOME_VARIABLE_MULTIARCH_0' "$context_name"
}

test_context_name_archive() {
	local ARCHIVE SOME_VARIABLE SOME_VARIABLE_MULTIARCH SOME_VARIABLE_MULTIARCH_0 context_name_archive
	ARCHIVE='ARCHIVE_BASE_MULTIARCH_0'
	context_name_archive=$(context_name_archive 'SOME_VARIABLE')
	assertNull "$context_name_archive"
	SOME_VARIABLE='some value'
	context_name_archive=$(context_name_archive 'SOME_VARIABLE')
	assertNull "$context_name_archive"
	SOME_VARIABLE_MULTIARCH='some value'
	context_name_archive=$(context_name_archive 'SOME_VARIABLE')
	assertEquals 'SOME_VARIABLE_MULTIARCH' "$context_name_archive"
	SOME_VARIABLE_MULTIARCH_0='some value'
	context_name_archive=$(context_name_archive 'SOME_VARIABLE')
	assertEquals 'SOME_VARIABLE_MULTIARCH_0' "$context_name_archive"
}

test_context_name_package() {
	local PKG SOME_VARIABLE SOME_VARIABLE_BIN32 context_name_package
	PKG='PKG_BIN32'
	context_name_package=$(context_name_package 'SOME_VARIABLE')
	assertNull "$context_name_package"
	SOME_VARIABLE='some value'
	context_name_package=$(context_name_package 'SOME_VARIABLE')
	assertNull "$context_name_package"
	SOME_VARIABLE_BIN32='some value'
	context_name_package=$(context_name_package 'SOME_VARIABLE')
	assertEquals 'SOME_VARIABLE_BIN32' "$context_name_package"
}

test_context_value() {
	local ARCHIVE PKG SOME_VARIABLE SOME_VARIABLE_BIN32 SOME_VARIABLE_MULTIARCH SOME_VARIABLE_MULTIARCH_0 context_value
	ARCHIVE='ARCHIVE_BASE_MULTIARCH_0'
	PKG='PKG_BIN32'
	context_value=$(context_value 'SOME_VARIABLE')
	assertNull "$context_value"
	SOME_VARIABLE='some value'
	context_value=$(context_value 'SOME_VARIABLE')
	assertEquals 'some value' "$context_value"
	SOME_VARIABLE_BIN32='some value specific to PKG_BIN32'
	context_value=$(context_value 'SOME_VARIABLE')
	assertEquals 'some value specific to PKG_BIN32' "$context_value"
	SOME_VARIABLE_MULTIARCH='some value specific to ARCHIVE_BASE_MULTIARCH_*'
	context_value=$(context_value 'SOME_VARIABLE')
	assertEquals 'some value specific to ARCHIVE_BASE_MULTIARCH_*' "$context_value"
	SOME_VARIABLE_MULTIARCH_0='some value specific to ARCHIVE_BASE_MULTIARCH_0'
	context_value=$(context_value 'SOME_VARIABLE')
	assertEquals 'some value specific to ARCHIVE_BASE_MULTIARCH_0' "$context_value"
}
