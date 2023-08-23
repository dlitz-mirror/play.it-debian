# Gentoo - Print installation instructions
# USAGE: print_instructions_gentoo $package[…]
print_instructions_gentoo() {
	local option_output_dir string_format
	option_output_dir=$(option_value 'output-dir')
	if printf '%s' "$option_output_dir" | grep --quiet --fixed-strings ' '; then
		string_format=' "%s"'
	else
		string_format=' %s'
	fi

	printf 'quickunpkg --'

	local package package_name package_output
	for package in "$@"; do
		package_name=$(package_name "$package")
		package_output=$(realpath "${option_output_dir}/${package_name}")
		printf "$string_format" "$package_output"
	done

	printf ' # https://downloads.dotslashplay.it/resources/gentoo/ '
	information_installation_instructions_gentoo_comment
	printf '\n'
}
