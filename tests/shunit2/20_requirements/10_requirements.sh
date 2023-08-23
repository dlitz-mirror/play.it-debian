#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set some required options
	PLAYIT_OPTION_ICONS=1
}

test_requirements_list() {
	local SCRIPT_DEPS ARCHIVE ARCHIVE_BASE_0_EXTRACTOR requirements_list requirements_list_expected
	SCRIPT_DEPS='command1 command2 command3'
	ARCHIVE='ARCHIVE_BASE_0'
	ARCHIVE_BASE_0_EXTRACTOR='unzip'
	requirements_list=$(requirements_list)
	requirements_list_expected='command1
command2
command3
unzip'
	assertEquals "$requirements_list_expected" "$requirements_list"
}

test_requirements_list_checksum() {
	local requirements_list
	option_update 'checksum' 'md5'
	requirements_list=$(requirements_list_checksum)
	assertEquals 'md5sum' "$requirements_list"
}

test_requirements_list_package() {
	local requirements_list requirements_list_expected
	option_update 'package' 'deb'
	requirements_list=$(requirements_list_package)
	requirements_list_expected='fakeroot
dpkg-deb'
	assertEquals "$requirements_list_expected" "$requirements_list"
}

test_requirements_list_icons() {
	local APPLICATIONS_LIST APP_MAIN_ICONS_LIST APP_MAIN_ICON requirements_list requirements_list_expected
	APPLICATIONS_LIST='APP_MAIN'
	APP_MAIN_ICONS_LIST='APP_MAIN_ICON'
	APP_MAIN_ICON='icon.exe'
	requirements_list=$(requirements_list_icons)
	requirements_list_expected='identify
convert
wrestool'
	assertEquals "$requirements_list_expected" "$requirements_list"
}

test_requirements_list_archive() {
	local ARCHIVE ARCHIVE_BASE_0_TYPE ARCHIVE_BASE_0_PART1 ARCHIVE_BASE_0_PART1_TYPE requirements_list requirements_list_expected
	ARCHIVE='ARCHIVE_BASE_0'
	ARCHIVE_BASE_0_TYPE='innosetup'
	ARCHIVE_BASE_0_PART1='setup_something-1.bin'
	ARCHIVE_BASE_0_PART1_TYPE='rar'
	requirements_list_expected='innoextract
unar'
	requirements_list=$(requirements_list_archive)
	assertEquals "$requirements_list_expected" "$requirements_list"
}

test_requirements_list_archive_single() {
	local ARCHIVE_BASE_0_TYPE ARCHIVE_BASE_0_EXTRACTOR requirements_list requirements_list_expected
	ARCHIVE_BASE_0_TYPE='mojosetup'
	requirements_list=$(requirements_list_archive_single 'ARCHIVE_BASE_0')
	requirements_list_expected='head
sed
wc
tr
gzip
tar
unzip'
	assertEquals "$requirements_list_expected" "$requirements_list"
	ARCHIVE_BASE_0_EXTRACTOR='innosetup'
	requirements_list=$(requirements_list_archive_single 'ARCHIVE_BASE_0')
	assertEquals 'innosetup' "$requirements_list"
}

test_dependency_provided_by() {
	local provider
	provider=$(dependency_provided_by 'bsdtar')
	assertEquals 'libarchive' "$provider"
}
