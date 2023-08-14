#!/bin/sh

source_functions_counter=0
tested_functions_counter=0
while read source_file; do
	printf 'Testing shUnit2 coverage for %s…\n' "$source_file"
	while read source_function; do
		test -n "$source_function" || continue
		source_functions_counter=$((source_functions_counter + 1))
		test_function="test_${source_function}"
		if grep --quiet "^${test_function}() {" tests/shunit2/*/*.sh; then
			tested_functions_counter=$((tested_functions_counter + 1))
			printf '\033[1;32m[Found]\033[0m %s\n' "$source_function"
		else
			printf '\033[1;31m[Missing]\033[0m %s\n' "$source_function"
		fi
	done <<- EOL
	$(sed --silent 's/^\([^\s].*\)() {/\1/p' "$source_file")
	EOL
done << EOL
$(find src/ -name \*.sh ! -name 90_messages.sh | LANG=C sort)
EOL

printf '\n%s/%s functions are covered by unit tests.\n' "$tested_functions_counter" "$source_functions_counter"
