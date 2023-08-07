#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set up a couple fake game scripts
	TEST_TEMP_DIR=$(mktemp --directory)
	export TEST_TEMP_DIR
	mkdir \
		"${TEST_TEMP_DIR}/00_scripts-collection" \
		"${TEST_TEMP_DIR}/99_old-scripts-collection"
	touch \
		"${TEST_TEMP_DIR}/00_scripts-collection/play-some-game.sh" \
		"${TEST_TEMP_DIR}/00_scripts-collection/play-some-other-game.sh" \
		"${TEST_TEMP_DIR}/99_old-scripts-collection/play-some-game.sh"
	cat > "${TEST_TEMP_DIR}/00_scripts-collection/play-some-game.sh" <<- EOF
	ARCHIVE_BASE_0='some_game_archive.tar.gz'
	EOF
	cat > "${TEST_TEMP_DIR}/00_scripts-collection/play-some-other-game.sh" <<- EOF
	ARCHIVE_BASE_0='another_game_archive.zip'
	EOF
	cat > "${TEST_TEMP_DIR}/99_old-scripts-collection/play-some-game.sh" <<- EOF
	ARCHIVE_MAIN='some_game_archive.tar.gz'
	EOF
}

oneTimeTearDown() {
	rm --force --recursive "$TEST_TEMP_DIR"
}

test_games_list_scripts_all() {
	local game_scripts_list game_scripts_list_expected

	# Use a fake list of sources, because we can not rely on real game scripts being available
	games_list_sources() {
		printf '%s\n' \
			"${TEST_TEMP_DIR}/00_scripts-collection" \
			"${TEST_TEMP_DIR}/99_old-scripts-collection"
	}

	game_scripts_list_expected="${TEST_TEMP_DIR}/00_scripts-collection/play-some-game.sh
${TEST_TEMP_DIR}/00_scripts-collection/play-some-other-game.sh
${TEST_TEMP_DIR}/99_old-scripts-collection/play-some-game.sh"
	game_scripts_list=$(games_list_scripts_all)
	assertEquals "$game_scripts_list_expected" "$game_scripts_list"
}

test_games_find_scripts_for_archive() {
	local game_scripts game_scripts_expected

	# Use a fake list of sources, because we can not rely on real game scripts being available
	games_list_sources() {
		printf '%s\n' \
			"${TEST_TEMP_DIR}/00_scripts-collection" \
			"${TEST_TEMP_DIR}/99_old-scripts-collection"
	}

	game_scripts_expected="${TEST_TEMP_DIR}/00_scripts-collection/play-some-game.sh
${TEST_TEMP_DIR}/99_old-scripts-collection/play-some-game.sh"
	game_scripts=$(games_find_scripts_for_archive 'some_game_archive.tar.gz')
	assertEquals "$game_scripts_expected" "$game_scripts"
}

test_games_find_script_for_archive() {
	local game_script game_script_expected

	# Use a fake list of sources, because we can not rely on real game scripts being available
	games_list_sources() {
		printf '%s\n' \
			"${TEST_TEMP_DIR}/00_scripts-collection" \
			"${TEST_TEMP_DIR}/99_old-scripts-collection"
	}

	game_script_expected="${TEST_TEMP_DIR}/00_scripts-collection/play-some-game.sh"
	game_script=$(games_find_script_for_archive 'some_game_archive.tar.gz')
	assertEquals "$game_script_expected" "$game_script"
}
