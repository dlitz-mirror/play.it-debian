#!/bin/sh

oneTimeSetUp() {
	# Load the ./play.it library
	export LIB_ONLY=1
	. lib/libplayit2.sh
	# Set required environment variables
	if [ -z "${XDG_CONFIG_PATH:-}" ]; then
		XDG_CONFIG_PATH="${HOME}/.config"
	fi
	# Set a fake configuration file
	TEST_TEMP_DIR=$(mktemp --directory)
	TEST_CONFIG_FILE="${TEST_TEMP_DIR}/config"
	cat > "$TEST_CONFIG_FILE" <<- EOF
	--tmpdir /var/tmp/play.it
	EOF
}

oneTimeTearDown() {
	rm --force --recursive "$TEST_TEMP_DIR"
}

test_load_configuration_file() {
	local option_tmpdir
	load_configuration_file "$TEST_CONFIG_FILE"

	option_tmpdir=$(option_value 'tmpdir')
	assertEquals '/var/tmp/play.it' "$option_tmpdir"
}

test_find_configuration_file() {
	local configuration_file

	configuration_file=$(find_configuration_file)
	assertEquals "${XDG_CONFIG_PATH}/play.it/config" "$configuration_file"

	configuration_file=$(find_configuration_file --config-file "$TEST_CONFIG_FILE")
	assertEquals "$TEST_CONFIG_FILE" "$configuration_file"
}

test_configuration_file_default_path() {
	local configuration_file
	configuration_file=$(configuration_file_default_path)
	assertEquals "${XDG_CONFIG_PATH}/play.it/config" "$configuration_file"
}
