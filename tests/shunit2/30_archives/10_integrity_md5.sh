#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
}

test_archive_get_md5sum_cached() {
	local SOURCE_ARCHIVE archive_md5sum_cached

	SOURCE_ARCHIVE_CACHED_MD5SUM='6c9bd7e1cf88fdbfa0e75f694bf8b0e5'
	archive_md5sum_cached=$(archive_get_md5sum_cached 'SOURCE_ARCHIVE')
	assertEquals '6c9bd7e1cf88fdbfa0e75f694bf8b0e5' "$archive_md5sum_cached"

	unset SOURCE_ARCHIVE_CACHED_MD5SUM
	archive_md5sum_cached=$(archive_get_md5sum_cached 'SOURCE_ARCHIVE')
	assertNull "$archive_md5sum_cached"
}

test_archive_has_md5sum_cached() {
	local SOURCE_ARCHIVE

	SOURCE_ARCHIVE_CACHED_MD5SUM='6c9bd7e1cf88fdbfa0e75f694bf8b0e5'
	assertTrue "archive_has_md5sum_cached 'SOURCE_ARCHIVE'"

	unset SOURCE_ARCHIVE_CACHED_MD5SUM
	assertFalse "archive_has_md5sum_cached 'SOURCE_ARCHIVE'"
}
