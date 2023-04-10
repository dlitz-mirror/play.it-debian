# Debian - Print installation instructions
# USAGE: debian_install_instructions $package[…]
debian_install_instructions() {
	if [ "${PLAYIT_DEBIAN_OLD_DEB_FORMAT:-0}" -eq 1 ]; then
		debian_install_instructions_dpkg "$@"
	else
		debian_install_instructions_apt "$@"
	fi
}

# Debian - Print installation instructions, using apt
# USAGE: debian_install_instructions_apt $package[…]
debian_install_instructions_apt() {
	local option_output_dir string_format
	option_output_dir=$(option_value 'output-dir')
	if printf '%s' "$option_output_dir" | grep --quiet --fixed-strings ' '; then
		string_format=' "%s"'
	else
		string_format=' %s'
	fi

	printf 'apt install'

	local package package_name package_output string_format
	for package in "$@"; do
		package_name=$(package_name "$package")
		package_output=$(realpath "${option_output_dir}/${package_name}")
		printf "$string_format" "$package_output"
	done

	printf '\n'
}

# Debian - Print installation instructions, using dpkg
# USAGE: debian_install_instructions_dpkg $package[…]
debian_install_instructions_dpkg() {
	local option_output_dir string_format
	option_output_dir=$(option_value 'output-dir')
	if printf '%s' "$option_output_dir" | grep --quiet --fixed-strings ' '; then
		string_format=' "%s"'
	else
		string_format=' %s'
	fi

	printf 'dpkg --install'

	local package package_name package_output string_format
	for package in "$@"; do
		package_name=$(package_name "$package")
		package_output=$(realpath "${option_output_dir}/${package_name}")
		printf "$string_format" "$package_output"
	done

	printf '\n'
	printf 'apt-get install --fix-broken\n\n'

	local message
	# shellcheck disable=SC2031
	case "${LANG%_*}" in
		('fr')
			message='Les éventuelles erreurs de dépendances suite à la commande dpkg peuvent être ignorées,'
			message="$message"' elles seront corrigées par la commande apt-get à entrer ensuite.\n'
		;;
		('en'|*)
			message='Potential errors related to dependencies after the dpkg command can be ignored,'
			message="$message"' they will be fixed by the command apt-get to run afterwards.\n'
		;;
	esac
	printf "$message"
}
