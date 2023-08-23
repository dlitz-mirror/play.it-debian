#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set required options
	PLAYIT_OPTION_FREE_SPACE_CHECK=0
	PLAYIT_OPTION_PACKAGE='deb'
	PLAYIT_OPTION_PREFIX='/usr'
	script_version='19700101.1'
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

test_applications_list() {
	local APPLICATIONS_LIST UNITY3D_NAME applications_list

	applications_list=$(applications_list)
	assertNull "$applications_list"

	UNITY3D_NAME='SomeName'
	applications_list=$(applications_list)
	assertEquals 'APP_MAIN' "$applications_list"

	APPLICATIONS_LIST='APP_MAIN APP_CONFIG APP_EDITOR'
	applications_list=$(applications_list)
	assertEquals 'APP_MAIN APP_CONFIG APP_EDITOR' "$applications_list"

	# Generating the applications list by parsing the game script can not be easily tested here.
}

test_application_prefix_type() {
	local APPLICATIONS_PREFIX_TYPE APP_MAIN_TYPE APP_MAIN_PREFIX_TYPE application_prefix_type

	APP_MAIN_TYPE='native'
	application_prefix_type=$(application_prefix_type 'APP_MAIN')
	assertEquals 'symlinks' "$application_prefix_type"
	
	APP_MAIN_TYPE='scummvm'
	application_prefix_type=$(application_prefix_type 'APP_MAIN')
	assertEquals 'none' "$application_prefix_type"

	APPLICATIONS_PREFIX_TYPE='symlinks'	
	application_prefix_type=$(application_prefix_type 'APP_MAIN')
	assertEquals 'symlinks' "$application_prefix_type"

	APP_MAIN_PREFIX_TYPE='none'
	application_prefix_type=$(application_prefix_type 'APP_MAIN')
	assertEquals 'none' "$application_prefix_type"
}

test_application_id() {
	local GAME_ID APP_MAIN_ID application_id

	GAME_ID='some-game'
	application_id=$(application_id 'APP_MAIN')
	assertEquals 'some-game' "$application_id"

	APP_MAIN_ID='some-application'
	application_id=$(application_id 'APP_MAIN')
	assertEquals 'some-application' "$application_id"

	# Check the format restriction
	APP_MAIN_ID='-some-invalid-application-id'
	assertFalse 'application_id "APP_MAIN"'
}

test_application_exe() {
	local APP_MAIN_EXE UNITY3D_NAME application_exe

	unity3d_application_exe_default() {
		printf 'SomeGame.x86_64'
	}
	UNITY3D_NAME='SomeGame'
	application_exe=$(application_exe 'APP_MAIN')
	assertEquals 'SomeGame.x86_64' "$application_exe"

	APP_MAIN_EXE='SomeGame.exe'
	application_exe=$(application_exe 'APP_MAIN')
	assertEquals 'SomeGame.exe' "$application_exe"
}

test_application_exe_escaped() {
	local APP_MAIN_EXE application_exe_escaped

	APP_MAIN_EXE="Some'Tricky'Name.x86"
	application_exe_escaped=$(application_exe_escaped 'APP_MAIN')
	assertEquals "Some'\''Tricky'\''Name.x86" "$application_exe_escaped"
}

test_application_exe_path() {
	local \
		PLAYIT_OPTION_TMPDIR GAME_ID APP_MAIN_EXE \
		CONTENT_PATH_DEFAULT fake_binary application_exe_path \
		PKG PKG_MAIN_ID \
		PACKAGES_LIST PKG_BIN32_ID PKG_BIN64_ID PKG_DATA_ID

	# Create a couple files in the temporary directory, and set required variables.
	PLAYIT_OPTION_TMPDIR="$TEST_TEMP_DIR"
	GAME_ID='some-game'
	APP_MAIN_EXE='SomeGame.exe'
	set_temp_directories
	mkdir --parents \
		"${PLAYIT_WORKDIR}/gamedata" \
		"${PLAYIT_WORKDIR}/packages/some-game-main_1.0-1+19700101.1_all/usr/share/games/some-game" \
		"${PLAYIT_WORKDIR}/packages/some-game-bin64_1.0-1+19700101.1_all/usr/share/games/some-game"
	touch \
		"${PLAYIT_WORKDIR}/gamedata/SomeGame.exe" \
		"${PLAYIT_WORKDIR}/packages/some-game-main_1.0-1+19700101.1_all/usr/share/games/some-game/SomeGame.exe" \
		"${PLAYIT_WORKDIR}/packages/some-game-bin64_1.0-1+19700101.1_all/usr/share/games/some-game/SomeGame.exe"

	# Look in archive contents
	CONTENT_PATH_DEFAULT='.'
	application_exe_path=$(application_exe_path "$APP_MAIN_EXE")
	assertEquals "${PLAYIT_WORKDIR}/gamedata/./SomeGame.exe" "$application_exe_path"
	unset CONTENT_PATH_DEFAULT

	# Look in the current package
	PKG='PKG_MAIN'
	PKG_MAIN_ID='some-game-main'
	application_exe_path=$(application_exe_path "$APP_MAIN_EXE")
	assertEquals "${PLAYIT_WORKDIR}/packages/some-game-main_1.0-1+19700101.1_all/usr/share/games/some-game/SomeGame.exe" "$application_exe_path"
	unset PKG PKG_MAIN_ID

	# Look in all packages
	PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'
	PKG_BIN32_ID='some-game-bin32'
	PKG_BIN64_ID='some-game-bin64'
	PKG_DATA_ID='some-game-data'
	application_exe_path=$(application_exe_path "$APP_MAIN_EXE")
	assertEquals "${PLAYIT_WORKDIR}/packages/some-game-bin64_1.0-1+19700101.1_all/usr/share/games/some-game/SomeGame.exe" "$application_exe_path"
	unset PACKAGES_LIST PKG_BIN32_ID PKG_BIN64_ID PKG_DATA_ID
}

test_application_name() {
	local GAME_NAME APP_MAIN_NAME application_name

	GAME_NAME='Some Game'
	application_name=$(application_name 'APP_MAIN')
	assertEquals 'Some Game' "$application_name"

	APP_MAIN_NAME='Some Application'
	application_name=$(application_name 'APP_MAIN')
	assertEquals 'Some Application' "$application_name"
}

test_application_category() {
	local APP_MAIN_CAT application_category

	application_category=$(application_category 'APP_MAIN')
	assertEquals 'Game' "$application_category"

	APP_MAIN_CAT='Settings'
	application_category=$(application_category 'APP_MAIN')
	assertEquals 'Settings' "$application_category"
}

test_application_prerun() {
	local APP_MAIN_PRERUN APP_MAIN_TYPE target_version application_prerun

	APP_MAIN_TYPE='native'
	APP_MAIN_PRERUN='some commands'
	application_prerun=$(application_prerun 'APP_MAIN')
	assertEquals 'some commands' "$application_prerun"

	# For DOSBox games targeting ./play.it ≤ 2.19, APP_xxx_PRERUN should be ignored here
	APP_MAIN_TYPE='dosbox'
	target_version='2.19'
	application_prerun=$(application_prerun 'APP_MAIN')
	assertNull "$application_prerun"
}

test_application_postrun() {
	local APP_MAIN_POSTRUN APP_MAIN_TYPE target_version application_postrun

	APP_MAIN_TYPE='native'
	APP_MAIN_POSTRUN='some commands'
	application_postrun=$(application_postrun 'APP_MAIN')
	assertEquals 'some commands' "$application_postrun"

	# For DOSBox games targeting ./play.it ≤ 2.19, APP_xxx_POSTRUN should be ignored here
	APP_MAIN_TYPE='dosbox'
	target_version='2.19'
	application_postrun=$(application_postrun 'APP_MAIN')
	assertNull "$application_postrun"
}

test_application_options() {
	local APP_MAIN_OPTIONS application_options

	application_options=$(application_options 'APP_MAIN')
	assertNull "$application_options"

	APP_MAIN_OPTIONS='--some-option --some-other-option'
	application_options=$(application_options 'APP_MAIN')
	assertEquals '--some-option --some-other-option' "$application_options"

	# Ensure that line breaks are not allowed
	APP_MAIN_OPTIONS='--some-option
--some-other-option'
	assertFalse 'application_options failed to correctly prevent a multi-lines options string.' 'application_options "APP_MAIN"'

	return 0
}
