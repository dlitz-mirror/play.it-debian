#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
}

_test_version_is_at_least_generic() {
	local version_test_command
	version_test_command="$1"

	assertTrue "$version_test_command 1.42 2.0"
	assertTrue "$version_test_command 1.42 1.42"
	assertFalse "$version_test_command 1.42 1.0"
}

test_version_is_at_least() {
	_test_version_is_at_least_generic 'version_is_at_least'
}

test_version_is_at_least_dpkg() {
	_test_version_is_at_least_generic 'version_is_at_least_dpkg'
}

test_version_is_at_least_shell() {
	_test_version_is_at_least_generic 'version_is_at_least_shell'
}

test_assert_not_empty() {
	local empty not_empty
	empty=''
	not_empty='something'
	assertTrue "assert_not_empty 'not_empty'"
	assertFalse "assert_not_empty 'empty'"
	assertFalse "assert_not_empty 'not_set'"
}
