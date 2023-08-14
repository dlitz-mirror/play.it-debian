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

test_content_inclusion() {
	local PLAYIT_WORKDIR CONTENT_GAME_MAIN_PATH CONTENT_GAME_DATA_FILES

	# Create source files
	mkdir --parents "${TEST_TEMP_DIR}/gamedata"
	mkdir \
		"${TEST_TEMP_DIR}/gamedata/directory-to-include" \
		"${TEST_TEMP_DIR}/gamedata/directory-to-exclude"
	touch \
		"${TEST_TEMP_DIR}/gamedata/file-to-include" \
		"${TEST_TEMP_DIR}/gamedata/file-to-exclude"

	# Use a hardcoded destination
	package_path() {
		printf '%s/packages/destination-package' "$TEST_TEMP_DIR"
	}

	PLAYIT_WORKDIR="$TEST_TEMP_DIR"
	CONTENT_GAME_MAIN_PATH='.'
	CONTENT_GAME_MAIN_FILES='directory-to-include
file-to-include
missing-file'
	content_inclusion 'GAME_MAIN' 'PKG_MAIN' '/'

	paths_included=$(find "${TEST_TEMP_DIR}/packages/destination-package" | LANG=C sort)
	paths_included_expected="${TEST_TEMP_DIR}/packages/destination-package
${TEST_TEMP_DIR}/packages/destination-package/directory-to-include
${TEST_TEMP_DIR}/packages/destination-package/file-to-include"
	assertEquals "$paths_included_expected" "$paths_included"

	paths_excluded=$(find "${TEST_TEMP_DIR}/gamedata" | LANG=C sort)
	paths_excluded_expected="${TEST_TEMP_DIR}/gamedata
${TEST_TEMP_DIR}/gamedata/directory-to-exclude
${TEST_TEMP_DIR}/gamedata/file-to-exclude"
	assertEquals "$paths_excluded_expected" "$paths_excluded"
}

test_content_inclusion_include_file() {
	local paths_included_expected paths_included paths_excluded_expected paths_excluded

	# Create source files
	mkdir --parents "${TEST_TEMP_DIR}/gamedata"
	mkdir \
		"${TEST_TEMP_DIR}/gamedata/directory-to-include" \
		"${TEST_TEMP_DIR}/gamedata/directory-to-exclude"
	touch \
		"${TEST_TEMP_DIR}/gamedata/file-to-include" \
		"${TEST_TEMP_DIR}/gamedata/file-to-exclude"

	(
		cd "${TEST_TEMP_DIR}/gamedata"
		content_inclusion_include_file 'directory-to-include' "${TEST_TEMP_DIR}/packages/destination-package"
		content_inclusion_include_file 'file-to-include' "${TEST_TEMP_DIR}/packages/destination-package"
	)

	paths_included=$(find "${TEST_TEMP_DIR}/packages/destination-package" | LANG=C sort)
	paths_included_expected="${TEST_TEMP_DIR}/packages/destination-package
${TEST_TEMP_DIR}/packages/destination-package/directory-to-include
${TEST_TEMP_DIR}/packages/destination-package/file-to-include"
	assertEquals "$paths_included_expected" "$paths_included"

	paths_excluded=$(find "${TEST_TEMP_DIR}/gamedata" | LANG=C sort)
	paths_excluded_expected="${TEST_TEMP_DIR}/gamedata
${TEST_TEMP_DIR}/gamedata/directory-to-exclude
${TEST_TEMP_DIR}/gamedata/file-to-exclude"
	assertEquals "$paths_excluded_expected" "$paths_excluded"
}

test_content_inclusion_include_pattern() {
	local paths_included_expected paths_included paths_excluded_expected paths_excluded

	# Create source files
	mkdir --parents "${TEST_TEMP_DIR}/gamedata"
	mkdir \
		"${TEST_TEMP_DIR}/gamedata/directory-to-include" \
		"${TEST_TEMP_DIR}/gamedata/directory-to-exclude"
	touch \
		"${TEST_TEMP_DIR}/gamedata/file-to-include" \
		"${TEST_TEMP_DIR}/gamedata/file-to-exclude" \
		"${TEST_TEMP_DIR}/gamedata/directory-to-exclude/file-to-include" \
		"${TEST_TEMP_DIR}/gamedata/directory-to-exclude/file-to-exclude"

	(
		cd "${TEST_TEMP_DIR}/gamedata"
		content_inclusion_include_pattern '*-to-include' "${TEST_TEMP_DIR}/packages/destination-package"
	)

	paths_included=$(find "${TEST_TEMP_DIR}/packages/destination-package" | LANG=C sort)
	paths_included_expected="${TEST_TEMP_DIR}/packages/destination-package
${TEST_TEMP_DIR}/packages/destination-package/directory-to-exclude
${TEST_TEMP_DIR}/packages/destination-package/directory-to-exclude/file-to-include
${TEST_TEMP_DIR}/packages/destination-package/directory-to-include
${TEST_TEMP_DIR}/packages/destination-package/file-to-include"
	assertEquals "$paths_included_expected" "$paths_included"

	paths_excluded=$(find "${TEST_TEMP_DIR}/gamedata" | LANG=C sort)
	paths_excluded_expected="${TEST_TEMP_DIR}/gamedata
${TEST_TEMP_DIR}/gamedata/directory-to-exclude
${TEST_TEMP_DIR}/gamedata/directory-to-exclude/file-to-exclude
${TEST_TEMP_DIR}/gamedata/file-to-exclude"
	assertEquals "$paths_excluded_expected" "$paths_excluded"
}
