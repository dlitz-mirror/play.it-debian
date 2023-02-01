# print installation instructions for Debian
# USAGE: print_instructions_deb $pkg[…]
print_instructions_deb() {
	printf 'apt install'
	local option_output_dir package
	option_output_dir=$(option_value 'output-dir')
	for package in "$@"; do
		local package_name package_output
		package_name=$(package_name "$package")
		package_output=$(realpath "${option_output_dir}/${package_name}")
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

