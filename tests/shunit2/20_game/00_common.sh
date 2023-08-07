#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
}

test_game_id() {
	local GAME_ID game_id
	GAME_ID='some-game'
	game_id=$(game_id)
	assertEquals 'some-game' "$game_id"
}

test_expansion_id() {
	local EXPANSION_ID expansion_id
	EXPANSION_ID='some-expansion'
	expansion_id=$(expansion_id)
	assertEquals 'some-expansion' "$expansion_id"
}

test_game_id_validity_check() {
	assertTrue 'game_id_validity_check "valid-game-id"'
	assertFalse 'game_id_validity_check "invalid_game_id"'
}

test_game_name() {
	local GAME_NAME EXPANSION_NAME game_name
	GAME_NAME='Some Game'
	game_name=$(game_name)
	assertEquals 'Some Game' "$game_name"
	EXPANSION_NAME='Expansion 1'
	game_name=$(game_name)
	assertEquals 'Some Game - Expansion 1' "$game_name"
}
