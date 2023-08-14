#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
}

test_huge_files_list() {
	local HUGE_FILES_MAIN huge_files

	HUGE_FILES_MAIN='
some-big-file.pak'
	huge_files=$(huge_files_list 'PKG_MAIN')
	assertEquals 'some-big-file.pak' "$huge_files"

	# Check that duplicates are dropped
	HUGE_FILES_MAIN='
some-duplicated-file.pak
some-duplicated-file.pak'
	huge_files=$(huge_files_list 'PKG_MAIN')
	assertEquals 'some-duplicated-file.pak' "$huge_files"
}

test_content_inclusion_chunk_single() {
	local \
		GAME_ID PACKAGES_LIST \
		PKG_DATA_ID PKG_DATA_DESCRIPTION \
		PKG_DATA_CHUNK1_ID PKG_DATA_CHUNK1_DESCRIPTION PKG_DATA_CHUNK1_PRERM_RUN \
		CONTENT_GAME_DATA_CHUNK1_FILES

	# Skip the actual file inclusion
	path_game_data() {
		printf '/some/arbitrary/path'
	}
	content_inclusion() { return 0 ; }

	# Use a simplified function for returning the package description
	package_description() {
		context_value "${1}_DESCRIPTION"
	}

	PACKAGES_LIST='PKG_BIN PKG_DATA'
	PKG_DATA_ID='package-data'
	PKG_DATA_DESCRIPTION='data'
	content_inclusion_chunk_single 'PKG_DATA' 'some-file-chunk.pak.1' '1'
	assertEquals 'PKG_DATA_CHUNK1 PKG_BIN PKG_DATA' "$PACKAGES_LIST"
	assertEquals 'package-data-chunk1' "$PKG_DATA_CHUNK1_ID"
	assertEquals 'data - chunk 1' "$PKG_DATA_CHUNK1_DESCRIPTION"
	assertNotNull "$PKG_DATA_CHUNK1_PRERM_RUN"
	assertEquals 'some-file-chunk.pak.1' "$CONTENT_GAME_DATA_CHUNK1_FILES"
}
