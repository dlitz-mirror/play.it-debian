# print installation instructions for Debian
# USAGE: print_instructions_deb $pkg[…]
print_instructions_deb() {
	printf 'apt install'
	local package
	for package in "$@"; do
		local package_path package_name package_output
		package_path=$(package_get_path "$package")
		package_name=$(basename "$package_path")
		package_output=$(realpath "${OPTION_OUTPUT_DIR}/${package_name}.deb")
		local string_format
		if printf '%s' "$package_output" | grep --quiet ' '; then
			string_format=' "%s"'
		else
			string_format=' %s'
		fi
		# shellcheck disable=SC2059
		printf "$string_format" "$package_output"
	done
	printf '\n'
}

